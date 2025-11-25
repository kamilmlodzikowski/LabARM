# Lab 07 - ORB-SLAM3
## Download Dockerfile and build image
```shell
wget https://raw.githubusercontent.com/kamilmlodzikowski/LabARM/main/Lab07-ORB-SLAM/Dockerfile -O Dockerfile
wget https://raw.githubusercontent.com/kamilmlodzikowski/LabARM/main/Lab07-ORB-SLAM/arm_07_build.sh -O arm_07_build.sh
bash ./arm_07_build.sh 4
```

The ```arm_07_build.sh``` script accepts number of workers as an argument for parallel compilation:
```shell
bash ./arm_07_build.sh <number_of_workers>
```

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
