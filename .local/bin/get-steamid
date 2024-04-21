#!/bin/bash
steamapps="$HOME/.steam/steam/steamapps"
echo -n "\
-------------------------------------------------------------------------
Looking through ${steamapps}/compatdata/ ...
-------------------------------------------------------------------------
Proton    App ID      Name
"
for x in "$steamapps"/compatdata/*; do
    id=${x##*/}
    name=$(sed -n '/^\s*"name"\s*/ s///p' "$steamapps"/appmanifest_"$id".acf 2> /dev/null)
    printf "%-8s  %-10s  %s\n" \
        "$(< "$x"/version)" \
        "$id" \
        "${name:-this is not a Steam app?}"
done
