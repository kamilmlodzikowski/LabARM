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
