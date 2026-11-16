# Lab 07 - ORB-SLAM3

## Download Dockerfile and build image

```shell
wget https://raw.githubusercontent.com/kamilmlodzikowski/LabARM/main/Lab07-ORB-SLAM/Dockerfile -O Dockerfile
wget https://raw.githubusercontent.com/kamilmlodzikowski/LabARM/main/Lab07-ORB-SLAM/arm_07_build.sh -O arm_07_build.sh
bash ./arm_07_build.sh
```

The `arm_07_build.sh` script accepts:
- an optional number of workers (parallel compilers); by default it uses half of the CPU cores, but not more than the available memory allows (~2.5 GB per worker),
- an optional `--no-cache` flag (forces a clean rebuild),
- an optional `--no-datasets` flag (does not download the datasets, see below).

Examples:
```
# Build with default settings (using cache if available)
bash ./arm_07_build.sh

# Build with 2 workers and without using the Docker build cache
bash ./arm_07_build.sh 2 --no-cache
```

The image is based on `osrf/ros:lyrical-desktop-full` and contains [Pangolin](https://github.com/stevenlovegrove/Pangolin), [ORB-SLAM3](https://github.com/zang09/ORB-SLAM3-STEREO-FIXED), its [ROS 2 wrapper](https://github.com/kamilmlodzikowski/ORB_SLAM3_ROS2/tree/lyrical) and two datasets ([TUM-VI](https://cvg.cit.tum.de/data/datasets/visual-inertial-dataset) room4, PUT car). The build downloads ~5.2 GB of data (TUM-VI room4 2.3 GB, PUT car 2.9 GB); the image takes ~24 GB and the build needs ~25 GB of free disk space. In our test on a desktop PC the build took ~6 minutes without the datasets and ~17 minutes with them (most of it downloading).

## Alternative: build without the datasets and load them from a drive
If the datasets are available on a drive (the `Lab07-ORB-SLAM` directory with `bags/` and `arm_07_load_datasets.sh`), the image can be built without downloading them:
```shell
bash ./arm_07_build.sh --no-datasets
```

Then connect the drive and run the script from it (replace the path with the one where the drive is mounted):
```shell
bash /media/<user>/<drive>/Lab07-ORB-SLAM/arm_07_load_datasets.sh
```
The script checks the files and adds them to the `arm/lab07` image (~5 GB, a few minutes), so they are available in every container created by the run scripts below. The drive can be disconnected afterwards. The script can also be [downloaded](https://raw.githubusercontent.com/kamilmlodzikowski/LabARM/main/Lab07-ORB-SLAM/arm_07_load_datasets.sh) and given the path to the datasets as an argument.

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
