# Lab 11 - Problem 2
## Download Dockerfile and build image
```shell
wget https://raw.githubusercontent.com/kamilmlodzikowski/LabARM/main/Lab11-Problem2/Dockerfile -O Dockerfile
wget https://raw.githubusercontent.com/kamilmlodzikowski/LabARM/main/Lab11-Problem2/arm_11_build.sh
bash ./arm_11_build.sh 4
```

The ```arm_11_build.sh``` script accepts number of workers as an argument for parallel compilation:
```shell
bash ./arm_11_build.sh <number_of_workers>
```

## Running on Nvidia GPU
```shell
wget https://raw.githubusercontent.com/kamilmlodzikowski/LabARM/main/Lab11-Problem2/arm_11_run_gpu_nvidia.sh
bash ./arm_11_run_gpu_nvidia.sh
```

## Running on CPU
```shell
wget https://raw.githubusercontent.com/kamilmlodzikowski/LabARM/main/Lab11-Problem2/arm_11_run_cpu.sh
bash ./arm_11_run_cpu.sh
```
