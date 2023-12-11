# Lab 10 - LokalizacjaTopologiczna
## Download Dockerfile and build image
```shell
wget https://raw.githubusercontent.com/kamilmlodzikowski/LabARM/main/Lab10-LokalizacjaTopologiczna/Dockerfile
wget https://raw.githubusercontent.com/kamilmlodzikowski/LabARM/main/Lab10-LokalizacjaTopologiczna/arm_10_build.sh
bash ./arm_10_build.sh 4
```

The ```arm_10_build.sh``` script accepts number of workers as an argument for parallel compilation:
```shell
bash ./arm_10_build.sh <number_of_workers>
```

## Running on Nvidia GPU
```shell
wget https://raw.githubusercontent.com/kamilmlodzikowski/LabARM/main/Lab10-LokalizacjaTopologiczna/arm_10_run_gpu_nvidia.sh
bash ./arm_10_run_gpu_nvidia.sh
```

## Running on CPU
```shell
wget https://raw.githubusercontent.com/kamilmlodzikowski/LabARM/main/Lab10-LokalizacjaTopologiczna/arm_10_run_cpu.sh
bash ./arm_10_run_cpu.sh
```