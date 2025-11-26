#!/usr/bin/env bash
set -e

xhost +local:root

# IMAGE SETTINGS
ROS_IMAGE="arm/lab07"
DOCKERFILE="Dockerfile"
WORKERS=1
NO_CACHE=false

# --------- RESOURCE LIMITS ---------
# How many host CPUs may the build use?
# Here: at most half of available cores, but at least 1.
TOTAL_CPUS=$(nproc)
MAX_CPUS=$(( TOTAL_CPUS / 2 ))
(( MAX_CPUS < 1 )) && MAX_CPUS=1

# Build will only run on CPUs 0..MAX_CPUS-1
CPUSET="0-$((MAX_CPUS-1))"

# OPTIONAL: if you also want to cap RAM, uncomment:
# MEM_LIMIT="8g"   # e.g. limit build container to 8 GB RAM
# ----------------------------------

while [[ $# -gt 0 ]]; do
	case "$1" in
		-h|--help)
			echo "Usage: $0 [workers] [--no-cache]"
			exit 0
			;;
		--no-cache)
			NO_CACHE=true
			shift
			;;
		*)
			WORKERS="$1"
			shift
			;;
	esac
done

# Clamp requested workers to our CPU limit
if (( WORKERS > MAX_CPUS )); then
	echo "Requested $WORKERS workers, limiting to $MAX_CPUS to avoid overloading the machine"
	WORKERS=$MAX_CPUS
fi

echo "RUNNING WITH $WORKERS WORKER(S)"
echo "Dockerfile: $DOCKERFILE"
echo "Host CPUs: $TOTAL_CPUS, build limited to CPUs: $CPUSET"
$NO_CACHE && echo "Building with: --no-cache"

# Build options array for clarity
BUILD_OPTS=(
  --cpuset-cpus "$CPUSET"
  -f "$DOCKERFILE"
  --build-arg "parallel_workers=$WORKERS"
  -t "$ROS_IMAGE"
)

# Prepend --no-cache if requested
if $NO_CACHE; then
  BUILD_OPTS=(--no-cache "${BUILD_OPTS[@]}")
fi

# If you enable MEM_LIMIT above, also add:  -m "$MEM_LIMIT"
# BUILD_OPTS=(-m "$MEM_LIMIT" "${BUILD_OPTS[@]}")

# Optionally run with lower CPU priority:
# nice -n 10 docker build "${BUILD_OPTS[@]}" ./..

docker build "${BUILD_OPTS[@]}" ./..
