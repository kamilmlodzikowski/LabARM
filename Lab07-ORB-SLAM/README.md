# Lab 07 - ORB-SLAM3

## Download Dockerfile and build image

```shell
wget https://raw.githubusercontent.com/kamilmlodzikowski/LabARM/main/Lab07-ORB-SLAM/Dockerfile -O Dockerfile
wget https://raw.githubusercontent.com/kamilmlodzikowski/LabARM/main/Lab07-ORB-SLAM/arm_07_build.sh -O arm_07_build.sh
bash ./arm_07_build.sh 4
```

The `arm_07_build.sh` script accepts:
- an optional number of workers (for parallel compilation),
- an optional `--no-cache` flag (forces a clean rebuild).

Examples:
```
# Build with default settings (1 worker, using cache if available)
bash ./arm_07_build.sh

# Build with 4 workers
bash ./arm_07_build.sh 4

# Build with 2 workers and without using the Docker build cache
bash ./arm_07_build.sh 2 --no-cache
```

The image is based on `osrf/ros:lyrical-desktop-full` and contains [Pangolin](https://github.com/stevenlovegrove/Pangolin), [ORB-SLAM3](https://github.com/zang09/ORB-SLAM3-STEREO-FIXED), its [ROS 2 wrapper](https://github.com/kamilmlodzikowski/ORB_SLAM3_ROS2/tree/lyrical) and two datasets ([TUM-VI](https://cvg.cit.tum.de/data/datasets/visual-inertial-dataset) room4, PUT car). The build downloads ~5.2 GB of data (TUM-VI room4 2.3 GB, PUT car 2.9 GB) and took ~20 minutes with 4 workers in our test (half of it downloading); the image takes ~24 GB and the build needs ~25 GB of free disk space.

## Running on Nvidia GPU
```shell
wget https://raw.githubusercontent.com/kamilmlodzikowski/LabARM/main/Lab07-ORB-SLAM/arm_07_run_gpu_nvidia.sh -O arm_07_run_gpu_nvidia.sh
bash ./arm_07_run_gpu_nvidia.sh
```

## Running on CPU
```shell
wget https://raw.githubusercontent.com/kamilmlodzikowski/LabARM/main/Lab07-ORB-SLAM/arm_07_run_cpu.sh -O arm_07_run_cpu.sh
bash ./arm_07_run_cpu.sh
```
