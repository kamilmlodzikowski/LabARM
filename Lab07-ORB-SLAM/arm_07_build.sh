#!/usr/bin/env bash
set -e

xhost +local:root

# IMAGE SETTINGS
ROS_IMAGE="arm/lab07"
DOCKERFILE="Dockerfile"
WORKERS=""
NO_CACHE=false
DATASETS=true

# --------- RESOURCE LIMITS ---------
# How many host CPUs may the build use?
# Here: at most half of available cores, but at least 1.
TOTAL_CPUS=$(nproc)
MAX_CPUS=$(( TOTAL_CPUS / 2 ))
(( MAX_CPUS < 1 )) && MAX_CPUS=1

# Build will only run on CPUs 0..MAX_CPUS-1
CPUSET="0-$((MAX_CPUS-1))"

# How many compilers can run at once without running out of memory?
# Compiling ORB-SLAM3 takes up to ~2.5 GB per worker, so use at most available RAM / 2.5 GB.
MEM_AVAILABLE_GB=$(awk '/MemAvailable/ {printf "%d", $2 / 1024 / 1024}' /proc/meminfo)
MAX_MEM_WORKERS=$(( MEM_AVAILABLE_GB * 2 / 5 ))
(( MAX_MEM_WORKERS < 1 )) && MAX_MEM_WORKERS=1
# ----------------------------------

while [[ $# -gt 0 ]]; do
	case "$1" in
		-h|--help)
			echo "Usage: $0 [workers] [--no-cache] [--no-datasets]"
			echo "  workers        number of parallel compilers (default: as many as CPUs and memory allow)"
			echo "  --no-cache     rebuild everything"
			echo "  --no-datasets  do not download the datasets (~5 GB), add them later with arm_07_load_datasets.sh"
			exit 0
			;;
		--no-cache)
			NO_CACHE=true
			shift
			;;
		--no-datasets)
			DATASETS=false
			shift
			;;
		*)
			WORKERS="$1"
			shift
			;;
	esac
done

# Default: as many workers as allowed; clamp requested workers to our CPU and memory limits
[ -z "$WORKERS" ] && WORKERS=$MAX_CPUS
if (( WORKERS > MAX_CPUS )); then
	echo "Requested $WORKERS workers, limiting to $MAX_CPUS to avoid overloading the machine"
	WORKERS=$MAX_CPUS
fi
if (( WORKERS > MAX_MEM_WORKERS )); then
	echo "Limiting to $MAX_MEM_WORKERS workers, only ${MEM_AVAILABLE_GB} GB of memory is available"
	WORKERS=$MAX_MEM_WORKERS
fi

echo "RUNNING WITH $WORKERS WORKER(S)"
echo "Dockerfile: $DOCKERFILE"
echo "Host CPUs: $TOTAL_CPUS, build limited to CPUs: $CPUSET"
$NO_CACHE && echo "Building with: --no-cache"
$DATASETS || echo "Building without the datasets (add them with arm_07_load_datasets.sh)"

# Build options array for clarity
BUILD_OPTS=(
  --cpuset-cpus "$CPUSET"
  -f "$DOCKERFILE"
  --build-arg "parallel_workers=$WORKERS"
  --build-arg "datasets=$DATASETS"
  -t "$ROS_IMAGE"
)

# Prepend --no-cache if requested
if $NO_CACHE; then
  BUILD_OPTS=(--no-cache "${BUILD_OPTS[@]}")
fi

# Optionally run with lower CPU priority:
# nice -n 10 docker build "${BUILD_OPTS[@]}" ./..

docker build "${BUILD_OPTS[@]}" ./..
