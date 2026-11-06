#!/usr/bin/env bash
#
# collect-dependencies.sh <binary-or-so> <target-dir>
#
# Recursively collects all shared libraries needed by the given ELF file
# (using lddtree from pax-utils) and copies them into <target-dir>,
# preserving symlinks (e.g. libfoo.so.1 -> libfoo.so.1.2.3).
#
# Notes:
# - Designed for multi-stage Docker builds: run it in the builder stage,
#   then COPY the target dir into the final image and add it to
#   LD_LIBRARY_PATH (or an ld.so.conf entry).


set -euo pipefail

if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <binary-or-shared-lib> <target-dir>" >&2
    exit 1
fi

SRC="$1"
TARGET="$2"

if [[ ! -f "$SRC" ]]; then
    echo "Error: '$SRC' not found" >&2
    exit 1
fi

mkdir -p "$TARGET"
TARGET=$(cd "$TARGET" && pwd)

LDDTREE_ARGS=(-l)
if [[ -n "${LDDTREE_ROOT:-}" ]]; then
    LDDTREE_ARGS+=(-R "$LDDTREE_ROOT")
fi

# -l prints one resolved path per line, already deduplicated and recursive.
# Some lines may have a "prefix=" annotation (e.g. "prefix=/usr"); filter those.
mapfile -t libs < <(lddtree "${LDDTREE_ARGS[@]}" "$SRC" | grep -v '^prefix=' | sort -u)

if [[ ${#libs[@]} -eq 0 ]]; then
    echo "Error: lddtree found no dependencies for '$SRC'" >&2
    exit 1
fi

copied=0
for lib in "${libs[@]}"; do
    if [[ ! -e "$lib" ]]; then
        echo "Warning: '$lib' not found on disk, skipping" >&2
        continue
    fi

    # Skip anything already inside the target dir.
    real=$(realpath "$lib")
    if [[ "$real" == "$TARGET"/* ]]; then
        continue
    fi

    if [[ -L "$lib" ]]; then
        # Symlink: copy the real file, then recreate the link chain.
        realname=$(basename "$real")
        if [[ ! -e "$TARGET/$realname" ]]; then
            cp -L "$real" "$TARGET/$realname"
            copied=$((copied + 1))
        fi
        # Point the symlink at the *basename* so the folder is relocatable.
        ln -sf "$realname" "$TARGET/$(basename "$lib")"
    else
        if [[ ! -e "$TARGET/$(basename "$lib")" ]]; then
            cp "$lib" "$TARGET/"
            copied=$((copied + 1))
        fi
    fi
done

echo "Copied $copied unique libraries into $TARGET:"
ls -l "$TARGET"