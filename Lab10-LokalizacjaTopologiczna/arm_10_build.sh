#!/usr/bin/env bash
set -e

# IMAGE SETTINGS
ROS_IMAGE="arm/lab10"
DOCKERFILE="Dockerfile"
NO_CACHE=false
DATASETS=true

while [[ $# -gt 0 ]]; do
	case "$1" in
		-h|--help)
			echo "Usage: $0 [--no-cache] [--no-datasets]"
			echo "  --no-cache     rebuild everything"
			echo "  --no-datasets  do not download the dataset (~1.7 GB), add it later with arm_10_load_datasets.sh"
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
		[0-9]*)
			# number of workers in the old version of the script, nothing is compiled now
			shift
			;;
		*)
			echo "Unknown option $1, see $0 --help"
			exit 1
			;;
	esac
done

echo "Dockerfile: $DOCKERFILE"
$NO_CACHE && echo "Building with: --no-cache"
$DATASETS || echo "Building without the dataset (add it with arm_10_load_datasets.sh)"

BUILD_OPTS=(
  -f "$DOCKERFILE"
  --build-arg "datasets=$DATASETS"
  -t "$ROS_IMAGE"
)
if $NO_CACHE; then
  BUILD_OPTS=(--no-cache "${BUILD_OPTS[@]}")
fi

docker build "${BUILD_OPTS[@]}" ./..
