#!/bin/bash
# Loads the Lab 10 dataset (e.g. from a USB drive) into the arm/lab10 image built with
# arm_10_build.sh --no-datasets. It is added to the image, not to a running container,
# so it stays available when the run scripts create a new ARM_10 container.
#
# Usage: bash arm_10_load_datasets.sh [path]
#   path - directory with the dataset: the Lab10-LokalizacjaTopologiczna directory from the drive or
#          its bags/ subdirectory (default: the directory of this script, i.e. run it from the drive)

ROS_IMAGE="arm/lab10"
DATA_DIR="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
[ -d "$DATA_DIR/bags" ] && DATA_DIR="$DATA_DIR/bags"

# CHECK THE DATASET IS THERE
for f in fr3_long_office_household/metadata.yaml fr3_long_office_household/fr3_long_office_household.mcap; do
    if [ ! -r "$DATA_DIR/$f" ]; then
        echo "ERROR: cannot read $DATA_DIR/$f"
        echo "Give the path to the Lab10-LokalizacjaTopologiczna directory as an argument (if the files exist, but cannot be read, run the script with sudo)."
        exit 1
    fi
done

# CHECK THE IMAGE
if ! docker image inspect $ROS_IMAGE > /dev/null 2>&1; then
    echo "ERROR: image $ROS_IMAGE not found, build it first: bash arm_10_build.sh --no-datasets"
    exit 1
fi
if docker run --rm $ROS_IMAGE test -f /arm_ws/bags/fr3_long_office_household/metadata.yaml; then
    echo "Image $ROS_IMAGE already contains the dataset, nothing to do"
    exit 0
fi

# CHECK THE DATASET IS NOT DAMAGED
if [ -f "$DATA_DIR/SHA256SUMS" ]; then
    echo "Checking the files (takes a while)..."
    if ! (cd "$DATA_DIR" && sha256sum --quiet -c SHA256SUMS); then
        echo "ERROR: the dataset is damaged, copy it again"
        exit 1
    fi
fi

# ADD THE DATASET TO THE IMAGE
echo "Adding the dataset to $ROS_IMAGE (~2 GB)..."
docker build -t $ROS_IMAGE -f - "$DATA_DIR" << EOF || exit 1
FROM $ROS_IMAGE
COPY fr3_long_office_household /arm_ws/bags/fr3_long_office_household
EOF

echo
echo "Done. Create the container with arm_10_run_cpu.sh or arm_10_run_gpu_nvidia.sh."
echo "NOTE: the run scripts remove an existing ARM_10 container (and the files saved in it)."
