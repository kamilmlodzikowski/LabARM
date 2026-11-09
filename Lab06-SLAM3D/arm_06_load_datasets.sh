#!/bin/bash
# Loads the Lab 06 datasets (e.g. from a USB drive) into the arm/lab06 image built with
# arm_06_build_no_datasets.sh. They are added to the image, not to a running container,
# so they stay available when the run scripts create a new ARM_06 container.
#
# Usage: bash arm_06_load_datasets.sh [path]
#   path - directory with the datasets: the Lab06-SLAM3D directory from the drive or its bags/
#          subdirectory (default: the directory of this script, i.e. run it from the drive)

ROS_IMAGE="arm/lab06"
DATA_DIR="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
[ -d "$DATA_DIR/bags" ] && DATA_DIR="$DATA_DIR/bags"

# CHECK THE DATASETS ARE THERE
for f in hdl_400/metadata.yaml hdl_400/hdl_400.mcap kitti/metadata.yaml kitti/kitti2.db3 kitti_gt.tum; do
    if [ ! -r "$DATA_DIR/$f" ]; then
        echo "ERROR: cannot read $DATA_DIR/$f"
        echo "Give the path to the Lab06-SLAM3D directory as an argument (if the files exist, but cannot be read, run the script with sudo)."
        exit 1
    fi
done

# CHECK THE IMAGE
if ! docker image inspect $ROS_IMAGE > /dev/null 2>&1; then
    echo "ERROR: image $ROS_IMAGE not found, build it first: bash arm_06_build_no_datasets.sh"
    exit 1
fi
if docker run --rm $ROS_IMAGE test -f /arm_ws/bags/hdl_400/metadata.yaml; then
    echo "Image $ROS_IMAGE already contains the datasets, nothing to do"
    exit 0
fi

# CHECK THE DATASETS ARE NOT DAMAGED
if [ -f "$DATA_DIR/SHA256SUMS" ]; then
    echo "Checking the files (takes a while)..."
    if ! (cd "$DATA_DIR" && sha256sum --quiet -c SHA256SUMS); then
        echo "ERROR: the datasets are damaged, copy them again"
        exit 1
    fi
fi

# ADD THE DATASETS TO THE IMAGE
echo "Adding the datasets to $ROS_IMAGE (~3 GB)..."
docker build -t $ROS_IMAGE -f - "$DATA_DIR" << EOF || exit 1
FROM $ROS_IMAGE
COPY hdl_400 /arm_ws/bags/hdl_400
COPY kitti /arm_ws/bags/kitti
COPY kitti_gt.tum /arm_ws/bags/kitti_gt.tum
EOF

echo
echo "Done. Create the container with arm_06_run_cpu.sh or arm_06_run_gpu_nvidia.sh."
echo "NOTE: the run scripts remove an existing ARM_06 container (and the files saved in it)."
