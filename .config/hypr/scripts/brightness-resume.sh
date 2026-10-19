#!/usr/bin/env bash
set -u

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if [ ! -f "$script_dir/brightness-lib.sh" ]; then
    printf '%s: missing brightness-lib.sh next to the script; cannot restore\n' "${0##*/}" >&2
    exit 0
fi
. "$script_dir/brightness-lib.sh"

# Power the monitors on before touching DDC/CI. This script owns power-on so
# restoration never depends on another hypridle listener running first.
niri msg action power-on-monitors >/dev/null 2>&1 || true

# Resolve the per-user runtime state directory. Without it there is no saved
# brightness to restore, so report and stop (power-on above already happened).
state_dir=""
if [ -n "${XDG_RUNTIME_DIR:-}" ] && [ -d "$XDG_RUNTIME_DIR" ] && [ -w "$XDG_RUNTIME_DIR" ]; then
    state_dir="$XDG_RUNTIME_DIR/hypridle-brightness"
fi
if [ -z "$state_dir" ] || [ ! -d "$state_dir" ]; then
    printf '%s: XDG_RUNTIME_DIR is unset, empty, or unusable; cannot restore saved brightness\n' "${0##*/}" >&2
    exit 0
fi

# Restore the laptop/internal panel from the saved raw value.
internal_state="$state_dir/internal"
if [ -f "$internal_state" ]; then
    IFS= read -r internal < "$internal_state"
    case "${internal:-}" in
        ''|*[!0-9]*) ;;
        *) if brightnessctl set "$internal" >/dev/null 2>&1; then rm -f "$internal_state"; fi;;
    esac
fi

monitors_dir="$state_dir/monitors"
[ -d "$monitors_dir" ] || exit 0

# Give the monitors a moment to become DDC/CI responsive, then rediscover and
# restore. A saved state is only applied when its identity still matches a
# currently detected monitor; the selector is taken from the fresh discovery so
# a serial-less monitor keeps its identity even if its bus changed. Stale or
# ambiguous state is skipped and kept; state is removed only after a successful
# write. The loop retries, bounded, for slow-waking monitors.
sleep 1

discovery="$state_dir/.discovery"
attempts=0
while [ "$attempts" -lt 8 ]; do
    pending=0
    for f in "$monitors_dir"/*; do
        [ -f "$f" ] && { pending=1; break; }
    done
    [ "$pending" -eq 0 ] && break

    discover_monitors > "$discovery"

    for state_file in "$monitors_dir"/*; do
        [ -f "$state_file" ] || continue
        identity="${state_file##*/}"

        # New format: selector<TAB>selector_value<TAB>brightness.
        # Legacy format written by older versions: serial<TAB>brightness.
        IFS="$(printf '\t')" read -r f1 f2 f3 < "$state_file"
        case "${f1:-}" in
            sn|bus) value="${f3:-}"; want_serial="";;
            *)      value="${f2:-}"; want_serial="${f1:-}";;
        esac
        [ -n "$value" ] || continue
        case "$value" in
            ''|*[!0-9]*) continue;;
        esac

        msel=""; msv=""
        while IFS='|' read -r cid csel csv cserial cconn cbus; do
            if [ -n "$want_serial" ]; then
                [ "$cserial" = "$want_serial" ] && { msel="$csel"; msv="$csv"; break; }
            else
                [ "$cid" = "$identity" ] && { msel="$csel"; msv="$csv"; break; }
            fi
        done < "$discovery"

        if [ -z "$msel" ] || [ -z "$msv" ]; then
            continue
        fi
        ddc_set "$msel" "$msv" "$value" && rm -f "$state_file"
    done

    left=0
    for f in "$monitors_dir"/*; do
        [ -f "$f" ] && { left=1; break; }
    done
    [ "$left" -eq 0 ] && break

    attempts=$((attempts + 1))
    sleep 0.5
done

for state_file in "$monitors_dir"/*; do
    [ -f "$state_file" ] || continue
    printf '%s: could not restore saved state %s (monitor absent, changed, or unresponsive); keeping it\n' "${0##*/}" "${state_file##*/}" >&2
done
