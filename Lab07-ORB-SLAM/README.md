# Lab 06 - SLAM 3D
## Download Dockerfile and build image
```shell
wget https://raw.githubusercontent.com/kamilmlodzikowski/LabARM/main/Lab06-SLAM3D/Dockerfile
wget https://raw.githubusercontent.com/kamilmlodzikowski/LabARM/main/Lab06-SLAM3D/arm_06_build.sh
bash ./arm_06_build.sh 4
```

The ```arm_06_build.sh``` script accepts number of workers as an argument for parallel compilation:
```shell
bash ./arm_06_build.sh <number_of_workers>
```

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