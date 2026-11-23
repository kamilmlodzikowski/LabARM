# Lab 10 - LokalizacjaTopologiczna

## Download Dockerfile and build image

```shell
wget https://raw.githubusercontent.com/kamilmlodzikowski/LabARM/main/Lab10-LokalizacjaTopologiczna/Dockerfile -O Dockerfile
wget https://raw.githubusercontent.com/kamilmlodzikowski/LabARM/main/Lab10-LokalizacjaTopologiczna/arm_10_build.sh -O arm_10_build.sh
bash ./arm_10_build.sh
```

The `arm_10_build.sh` script accepts:
- an optional `--no-cache` flag (forces a clean rebuild),
- an optional `--no-datasets` flag (does not download the dataset, see below).

The image is based on `osrf/ros:lyrical-desktop-full` and contains [RTAB-Map](https://github.com/introlab/rtabmap_ros/tree/ros2) and the freiburg3_long_office_household sequence of the [TUM RGB-D dataset](https://cvg.cit.tum.de/data/datasets/rgbd-dataset), converted to ROS 2 (`/arm_ws/bags/fr3_long_office_household`). Nothing is compiled; the build downloads ~1.7 GB of data, the image takes ~16 GB and the build needs ~20 GB of free disk space. In our test on a desktop PC the build took ~5 minutes without the dataset and ~11 minutes with it (downloading and converting the data takes ~6 minutes).

## Alternative: build without the dataset and load it from a drive
If the dataset is available on a drive (the `Lab10-LokalizacjaTopologiczna` directory with `bags/` and `arm_10_load_datasets.sh`), the image can be built without downloading it:
```shell
bash ./arm_10_build.sh --no-datasets
```

Then connect the drive and run the script from it (replace the path with the one where the drive is mounted):
```shell
bash /media/<user>/<drive>/Lab10-LokalizacjaTopologiczna/arm_10_load_datasets.sh
```
The script checks the files and adds them to the `arm/lab10` image (~2 GB, a minute or two), so they are available in every container created by the run scripts below. The drive can be disconnected afterwards. The script can also be [downloaded](https://raw.githubusercontent.com/kamilmlodzikowski/LabARM/main/Lab10-LokalizacjaTopologiczna/arm_10_load_datasets.sh) and given the path to the dataset as an argument.

## Running on Nvidia GPU
```shell
wget https://raw.githubusercontent.com/kamilmlodzikowski/LabARM/main/Lab10-LokalizacjaTopologiczna/arm_10_run_gpu_nvidia.sh -O arm_10_run_gpu_nvidia.sh
bash ./arm_10_run_gpu_nvidia.sh
```

## Running on CPU
```shell
wget https://raw.githubusercontent.com/kamilmlodzikowski/LabARM/main/Lab10-LokalizacjaTopologiczna/arm_10_run_cpu.sh -O arm_10_run_cpu.sh
bash ./arm_10_run_cpu.sh
```
