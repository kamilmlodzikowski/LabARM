#!/usr/bin/env bash
# Creates the dataset drive for the labs that can load their datasets from a drive instead of
# downloading them while building the image (see README.md in this directory).
#
# For each lab it creates <target_dir>/<lab directory>/ with:
#   bags/                    the datasets, copied from /arm_ws/bags of the lab image built with the datasets
#   bags/SHA256SUMS          checksums, checked by the load script
#   arm_NN_load_datasets.sh  the lab's load script (from the lab directory of this repo)
#   README.txt               instructions for the students (from drive/<lab directory>/ here)
#
# Usage: bash make_dataset_drive.sh [options] <target_dir> [lab ...]
#   target_dir   the mounted drive (e.g. /media/<user>/<drive>) or a local directory
#   lab          lab number(s): 06 07 (default: all of them)
# Options:
#   -j N         parallel compilers when an image has to be built
#                (default: half of the CPUs, at most available memory / 2.5 GB)
#   --rebuild    build the images from the current Dockerfiles even if images with the datasets exist
#   --no-cache   build without the docker cache (downloads the datasets again; implies --rebuild)
set -e

# LABS: number -> directory in this repo and on the drive, and a file in /arm_ws/bags of the image
# that is there only when the image has the datasets. The image is arm/labNN, the load script
# <directory>/arm_NN_load_datasets.sh and the image is built from <directory>/Dockerfile.
declare -A LAB_DIR=( [06]=Lab06-SLAM3D [07]=Lab07-ORB-SLAM )
declare -A LAB_CHECK=( [06]=hdl_400/metadata.yaml [07]=room4/metadata.yaml )

TOOLS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$TOOLS_DIR")"

usage() {
    sed -n '/^# Usage:/,/^set -e/p' "${BASH_SOURCE[0]}" | sed '$d; s/^# \{0,1\}//'
    exit "${1:-0}"
}

WORKERS=""
REBUILD=false
NO_CACHE=()
TARGET=""
LABS=()
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help) usage ;;
        -j) WORKERS="$2"; shift 2 ;;
        --rebuild) REBUILD=true; shift ;;
        --no-cache) REBUILD=true; NO_CACHE=(--no-cache); shift ;;
        -*) echo "Unknown option $1"; usage 1 ;;
        *)
            if [ -z "$TARGET" ]; then
                TARGET="$1"
            else
                [[ "$1" =~ ^[0-9]+$ ]] && lab=$(printf "%02d" "$((10#$1))") || lab=""
                [ -n "$lab" ] && [ -n "${LAB_DIR[$lab]}" ] || { echo "ERROR: unknown lab $1 (known: $(printf "%s\n" "${!LAB_DIR[@]}" | sort | xargs))"; exit 1; }
                LABS+=("$lab")
            fi
            shift ;;
    esac
done
[ -n "$TARGET" ] || usage 1
[ ${#LABS[@]} -gt 0 ] || mapfile -t LABS < <(printf "%s\n" "${!LAB_DIR[@]}" | sort)

# Same limits as arm_07_build.sh: compiling ORB-SLAM3 takes up to ~2.5 GB per worker
if [ -z "$WORKERS" ]; then
    WORKERS=$(( $(nproc) / 2 ))
    MEM_WORKERS=$(awk '/MemAvailable/ {printf "%d", $2 / 1024 / 1024 * 2 / 5}' /proc/meminfo)
    (( WORKERS > MEM_WORKERS )) && WORKERS=$MEM_WORKERS
    (( WORKERS < 1 )) && WORKERS=1
fi

# Do not overwrite anything: stop before building if a lab directory is already there
mkdir -p "$TARGET"
TARGET="$(cd "$TARGET" && pwd)"
for lab in "${LABS[@]}"; do
    if [ -e "$TARGET/${LAB_DIR[$lab]}" ]; then
        echo "ERROR: $TARGET/${LAB_DIR[$lab]} already exists, remove it first or choose another target directory"
        exit 1
    fi
done

START=$SECONDS
for lab in "${LABS[@]}"; do
    dir="${LAB_DIR[$lab]}"
    image="arm/lab$lab"
    out="$TARGET/$dir"
    echo
    echo "=== Lab $lab: $dir"

    # 1. An image with the datasets: use the existing one or build it from the lab's Dockerfile
    if ! $REBUILD && docker image inspect "$image" > /dev/null 2>&1 &&
            docker run --rm "$image" test -f "/arm_ws/bags/${LAB_CHECK[$lab]}"; then
        echo "Using the existing image $image (it has the datasets; --rebuild builds it from the current Dockerfile)"
    else
        echo "Building $image with the datasets and $WORKERS worker(s) (takes a while)..."
        docker build "${NO_CACHE[@]}" -f "$REPO_DIR/$dir/Dockerfile" --build-arg "parallel_workers=$WORKERS" \
            -t "$image" "$REPO_DIR/$dir"
        if ! docker run --rm "$image" test -f "/arm_ws/bags/${LAB_CHECK[$lab]}"; then
            echo "ERROR: the built $image has no /arm_ws/bags/${LAB_CHECK[$lab]}, check its Dockerfile"
            exit 1
        fi
    fi

    # 2. Enough space?
    need=$(docker run --rm "$image" du -sb /arm_ws/bags | cut -f1)
    free=$(df --output=avail -B1 "$TARGET" | tail -n 1)
    if (( need > free )); then
        echo "ERROR: the datasets need $(( need / 1000000 )) MB, but only $(( free / 1000000 )) MB is free in $TARGET"
        exit 1
    fi

    # 3. Copy the datasets out of the image
    echo "Copying the datasets ($(( need / 1000000 )) MB) to $out..."
    mkdir -p "$out/bags"
    cid=$(docker create "$image")
    docker cp -q "$cid:/arm_ws/bags/." "$out/bags/" || { docker rm "$cid" > /dev/null; exit 1; }
    docker rm "$cid" > /dev/null

    # 4. Checksums, load script, README
    echo "Computing the checksums..."
    (cd "$out/bags" && find . -type f ! -name SHA256SUMS | sed 's|^\./||' | LC_ALL=C sort |
        xargs -d '\n' sha256sum > SHA256SUMS)
    cp "$REPO_DIR/$dir/arm_${lab}_load_datasets.sh" "$out/"
    cp "$TOOLS_DIR/drive/$dir/README.txt" "$out/"
    # readable for everyone (on ext4 the lab PCs see a different owner)
    chmod -R a+rX "$out"
done

echo
echo "Writing to the disk..."
sync
echo
for lab in "${LABS[@]}"; do du -sh "$TARGET/${LAB_DIR[$lab]}"; done
echo "Done in $(( (SECONDS - START) / 60 )) min. To check a drive, reconnect it and run in each lab's bags/: sha256sum -c SHA256SUMS"
