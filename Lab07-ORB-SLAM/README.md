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

### Building on low-resource machines
If the build regularly stalls due to RAM or CPU pressure, you can switch to a lighter Dockerfile that limits parallel compilation:
```shell
wget https://raw.githubusercontent.com/kamilmlodzikowski/LabARM/main/Lab07-ORB-SLAM/Dockerfile_low -O Dockerfile_low
bash ./arm_07_build.sh <number_of_workers> --low-resource
```
When `--low-resource` is provided the script uses `Dockerfile_low`, which lowers the internal `make` parallelism for Pangolin/ORB-SLAM3 so that the container consumes significantly less memory (at the expense of build time).

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
