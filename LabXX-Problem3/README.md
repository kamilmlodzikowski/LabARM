# Lab XX - Laboratorium problemowe 3
Delivery robot crossing a street on a signalised crosswalk (ROS 2 Jazzy + Gazebo Harmonic).
Simulation: [arm_crosswalk_sim](https://github.com/kamilmlodzikowski/arm_crosswalk_sim)

## Download Dockerfile and build image

```shell
wget https://raw.githubusercontent.com/kamilmlodzikowski/LabARM/main/LabXX-Problem3/Dockerfile -O Dockerfile
wget https://raw.githubusercontent.com/kamilmlodzikowski/LabARM/main/LabXX-Problem3/arm_XX_build.sh
bash ./arm_XX_build.sh
```

## Running on Nvidia GPU

```shell
wget https://raw.githubusercontent.com/kamilmlodzikowski/LabARM/main/LabXX-Problem3/arm_XX_run_gpu_nvidia.sh
bash ./arm_XX_run_gpu_nvidia.sh
```

## Running on CPU

```shell
wget https://raw.githubusercontent.com/kamilmlodzikowski/LabARM/main/LabXX-Problem3/arm_XX_run_cpu.sh
bash ./arm_XX_run_cpu.sh
```

## Starting the simulation (inside the container)

```shell
ros2 launch crosswalk_sim sim.launch.py
```

Other scenarios and parameters, e.g.:

```shell
ros2 launch crosswalk_sim sim.launch.py scenario:=hard seed:=42
ros2 launch crosswalk_sim sim.launch.py params:="red_runner.probability=0.8 red_runner.window=[2,6] pedestrians.crossing_rate=15"
```

Open another terminal in the running container:

```shell
docker exec -it ARM_XX bash
```

Drive the robot with the keyboard:

```shell
ros2 run teleop_twist_keyboard teleop_twist_keyboard
```

Topics, parameters and the referee are described in the
[arm_crosswalk_sim README](https://github.com/kamilmlodzikowski/arm_crosswalk_sim#readme).
