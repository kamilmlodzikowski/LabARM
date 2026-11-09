# Lab 06 - SLAM 3D
## Download Dockerfile and build image
```shell
wget https://raw.githubusercontent.com/kamilmlodzikowski/LabARM/main/Lab06-SLAM3D/Dockerfile -O Dockerfile
wget https://raw.githubusercontent.com/kamilmlodzikowski/LabARM/main/Lab06-SLAM3D/arm_06_build.sh
bash ./arm_06_build.sh 4
```

The ```arm_06_build.sh``` script accepts number of workers as an argument for parallel compilation:
```shell
bash ./arm_06_build.sh <number_of_workers>
```

The image is based on `osrf/ros:jazzy-desktop-full` and contains [KISS-ICP](https://github.com/PRBonn/kiss-icp), [GLIM](https://github.com/koide3/glim) (CPU version), [evo](https://github.com/MichaelGrupp/evo) and two datasets (KITTI 00 excerpt, hdl_400). The build downloads ~1.4 GB of data; the image takes ~10 GB and the build needs ~15 GB of free disk space.

## Alternative: build without the datasets and load them from a drive
If the datasets are available on a drive (the `Lab06-SLAM3D` directory with `bags/` and `arm_06_load_datasets.sh`), the image can be built without downloading them:
```shell
wget https://raw.githubusercontent.com/kamilmlodzikowski/LabARM/main/Lab06-SLAM3D/Dockerfile_no_datasets -O Dockerfile_no_datasets
wget https://raw.githubusercontent.com/kamilmlodzikowski/LabARM/main/Lab06-SLAM3D/arm_06_build_no_datasets.sh
bash ./arm_06_build_no_datasets.sh 4
```

Then connect the drive and run the script from it (replace the path with the one where the drive is mounted):
```shell
bash /media/<user>/<drive>/Lab06-SLAM3D/arm_06_load_datasets.sh
```
The script checks the files and adds them to the `arm/lab06` image (~3 GB, a few minutes), so they are available in every container created by the run scripts below. The drive can be disconnected afterwards. The script can also be [downloaded](https://raw.githubusercontent.com/kamilmlodzikowski/LabARM/main/Lab06-SLAM3D/arm_06_load_datasets.sh) and given the path to the datasets as an argument.

## Running on Nvidia GPU
```shell
wget https://raw.githubusercontent.com/kamilmlodzikowski/LabARM/main/Lab06-SLAM3D/arm_06_run_gpu_nvidia.sh
bash ./arm_06_run_gpu_nvidia.sh
```

## Running on CPU
```shell
wget https://raw.githubusercontent.com/kamilmlodzikowski/LabARM/main/Lab06-SLAM3D/arm_06_run_cpu.sh
bash ./arm_06_run_cpu.sh
```