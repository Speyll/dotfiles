#!/usr/bin/env bash
set -u

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if [ ! -f "$script_dir/brightness-lib.sh" ]; then
    printf '%s: missing brightness-lib.sh next to the script; not dimming\n' "${0##*/}" >&2
    exit 0
fi
. "$script_dir/brightness-lib.sh"

# Resolve a per-user runtime state directory. If XDG_RUNTIME_DIR is unset, empty
# or unusable, skip dimming entirely: dimming without a place to record the
# original would strand the displays at the dimmed level.
state_dir=""
if [ -n "${XDG_RUNTIME_DIR:-}" ] && [ -d "$XDG_RUNTIME_DIR" ] && [ -w "$XDG_RUNTIME_DIR" ]; then
    state_dir="$XDG_RUNTIME_DIR/hypridle-brightness"
    mkdir -p "$state_dir/monitors" 2>/dev/null || state_dir=""
fi
if [ -z "$state_dir" ]; then
    printf '%s: XDG_RUNTIME_DIR is unset, empty, or unusable; not dimming (cannot save the original brightness safely)\n' "${0##*/}" >&2
    exit 0
fi

# Dim the laptop/internal panel, if present. The original raw value is saved
# once; a repeated dim never overwrites it with the dimmed value.
internal_state="$state_dir/internal"
if [ ! -f "$internal_state" ]; then
    internal="$(brightnessctl get 2>/dev/null)"
    case "$internal" in
        ''|*[!0-9]*) internal="";;
    esac
    [ -n "$internal" ] && printf '%s\n' "$internal" > "$internal_state"
fi
[ -f "$internal_state" ] && brightnessctl set 10% >/dev/null 2>&1 || true

# Save and dim each discovered external monitor. The state identity comes from
# discover_monitors() (unique serial, else connector, else bus); the selector is
# always explicit. A monitor without a readable original brightness is skipped
# rather than guessed at.
while IFS='|' read -r identity selector sel_val serial connector bus; do
    [ -n "$identity" ] || continue

    state_file="$state_dir/monitors/$identity"

    if [ ! -f "$state_file" ]; then
        current="$(parse_ddc_brightness "$selector" "$sel_val")"
        [ -n "$current" ] || continue
        # Already at (or below) the dim level and nothing saved: the monitor is
        # already dimmed. Never record the dimmed value as the "original",
        # otherwise resume would "restore" it to the dim level forever.
        [ "$current" -le "$DIM_LEVEL" ] && continue
        printf '%s\t%s\t%s\n' "$selector" "$sel_val" "$current" > "$state_file"
        # Remember it across reboots too (used to rescue a stranded monitor).
        mkdir -p "$(persist_dir)" 2>/dev/null &&
            printf '%s\n' "$current" > "$(persist_dir)/$identity"
    fi

    ddc_set "$selector" "$sel_val" "$DIM_LEVEL"
done < <(discover_monitors)
