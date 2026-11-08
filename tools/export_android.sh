#!/bin/sh
# Export committed runtime files without Git or test evidence.
set -eu
source_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)
cd "$source_root"
git rev-parse --verify HEAD >/dev/null
release_version=$(git show HEAD:project.godot | sed -n 's/^config\/version="\([^"]*\)"$/\1/p')
destination=${1:-/storage/emulated/0/Download/GodotProjects/AternalSenia-$release_version-$(date +%Y%m%d-%H%M%S)}
if [ -e "$destination" ]; then
    printf '%s\n' "Destination exists; choose a new folder to avoid mixing versions: $destination" >&2
    exit 1
fi
archive=$(mktemp "${TMPDIR:-/tmp}/aternal-senia.XXXXXX")
trap 'rm -f "$archive"' EXIT HUP INT TERM
git archive --format=tar HEAD project.godot game art > "$archive"
mkdir -p -- "$destination"
tar -xf "$archive" -C "$destination"
printf '%s\n' "Open in Godot: $destination/project.godot"
printf '%s\n' "Exported committed HEAD only. Existing projects and player saves were not deleted."
