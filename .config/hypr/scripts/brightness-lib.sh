#!/usr/bin/env bash
# Shared DDC/CI helpers for brightness-dim.sh and brightness-resume.sh.
# This file is sourced, never executed directly.
#
# A monitor is always addressed through an explicit selector ("--sn" or
# "--bus"); we never rely on ddcutil's implicit first display.

# Read brightness (VCP 10) from an explicit selector. Prints nothing on failure.
ddc_get() { # selector value
    case "$1" in
        sn)  ddcutil --sn "$2" getvcp 10 --terse 2>/dev/null;;
        bus) ddcutil --bus "$2" getvcp 10 --terse 2>/dev/null;;
    esac
}

# Write brightness (VCP 10) to an explicit selector. Returns ddcutil's status.
ddc_set() { # selector value brightness
    case "$1" in
        sn)  ddcutil --sn "$2" setvcp 10 "$3" >/dev/null 2>&1;;
        bus) ddcutil --bus "$2" setvcp 10 "$3" >/dev/null 2>&1;;
    esac
}

# Validate a single `getvcp 10 --terse` continuous response. Accept only exactly
# one line in the "VCP 10 C cur max" form whose current value is a decimal
# integer in 0..100. Prints the validated value, or nothing.
parse_ddc_brightness() { # selector value
    ddc_get "$1" "$2" | awk '
        NF { lines++ }
        NF == 5 && $1 == "VCP" && $2 == "10" && $3 == "C" { val = $4 }
        END { if (lines == 1 && val ~ /^[0-9]+$/ && val + 0 <= 100) print val }
    '
}

# Discover DDC/CI monitors and print one unambiguous record per monitor:
#
#   identity|selector|selector_value|serial|connector|bus
#
# Empty fields are preserved (the reader must use IFS="|"). A monitor whose EDID
# serial is present and unique is identified by that serial; otherwise it is
# identified by its DRM connector (addressed by I2C bus), falling back to the
# bus. Records sharing an identity are dropped so an ambiguous monitor is never
# addressed. Input is `ddcutil detect --brief`; the "I2C bus:" and
# "DRM connector:" lines are optional and the block is keyed by "I2C bus:".
discover_monitors() {
    ddcutil detect --brief 2>/dev/null | awk '
        function sanitize(s) { gsub(/[^A-Za-z0-9._-]/, "_", s); return s }
        function flush() {
            if (bus != "") {
                n++
                rb[n] = bus; rc[n] = connector; rs[n] = serial
            }
            bus = ""; connector = ""; mfg = ""; model = ""; serial = ""
        }
        index($0, "I2C bus:") {
            flush()
            line = $0
            sub(/.*\/dev\/i2c-/, "", line)
            sub(/[^0-9].*/, "", line)
            bus = line
            next
        }
        index($0, "DRM connector:") {
            line = $0
            sub(/.*DRM connector:[ \t]*/, "", line)
            connector = line
            next
        }
        index($0, "Monitor:") {
            line = $0
            sub(/.*Monitor:[ \t]*/, "", line)
            split(line, p, ":")
            mfg = p[1]; model = p[2]; serial = p[3]
            next
        }
        END {
            flush()
            for (i = 1; i <= n; i++)
                if (rs[i] != "") serial_count[rs[i]]++
            for (i = 1; i <= n; i++) {
                if (rb[i] !~ /^[0-9]+$/) continue
                if (rs[i] != "" && serial_count[rs[i]] == 1) {
                    id = "sn-" sanitize(rs[i]); sel = "sn"; sv = rs[i]
                } else if (rc[i] != "") {
                    id = "cn-" sanitize(rc[i]); sel = "bus"; sv = rb[i]
                } else {
                    id = "bus-" rb[i]; sel = "bus"; sv = rb[i]
                }
                id_count[id]++
                oid[i] = id; osel[i] = sel; osv[i] = sv
            }
            for (i = 1; i <= n; i++) {
                if (id_count[oid[i]] == 1) {
                    print oid[i] "|" osel[i] "|" osv[i] "|" rs[i] "|" rc[i] "|" rb[i]
                } else if (!warned[oid[i]]++) {
                    print "brightness: skipping ambiguous monitor " oid[i] " (duplicate identity)" > "/dev/stderr"
                }
            }
        }
    '
}
