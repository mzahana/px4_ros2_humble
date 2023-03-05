# px4_ros2_humble
A Docker development environment for PX4 + ROS 2 Humble

# Build Docker Image

```bash 
cd px4_ros2_humble/docker
make px4-dev-ros2-humble
```

This builds a Docker image that has the required PX4 development environment, and ROS 2 Humble Desktop. It does not container the PX4 source code or any ROS 2 workspaces. This is covered in the following sections.

The Gazebo version in the provided Docker image is Gazebo Garden.

# Run
If you have NVIDIA GPU, run
```bash
./docker_run_nvidia.sh
```
Otherwise, run
```bash
./docker_run.sh
```

**NOTE**

Source files and workspaces should be saved inside a shared volume. The path to the shared volume inside the container is `/home/user/shared_volume`. The path to the shared volume in the host is `$HOME/px4_ros2_humble_shared_volume`

# Install PX4
It's recommended to have the `PX4-Autopilot` src and the ros 2 workspace(s) inside the shared volume, so you don't lose them if the container is removed.

* Enter the container `./docker_run.sh`
* Go to the shared volume `cd /home/user/shared_volume`
* Clone the `PX4-Autopilot` source 
    ```bash
    git clone https://github.com/PX4/PX4-Autopilot.git --recursive
    ```
* Enter the `PX4-Autopilot` directory (inside the ), clean, and build the source code
    ```bash
    cd PX4-Autopilot
    make clean
    make distclean
    git fetch origin release/1.13.2
    git checkout release/1.13.2
    make submodulesclean
    ```
* Test if PX4 can run  with the Gazebo simiulation 
    ```bash
    make px4_sitl gazebo-classic
    ```
    The XRCE-DDS client already runs with the above command
* The XRCE-DDS Agent is already built with the Docker image. In a new terminal, run the XRCE-DDS Agent
    ```bash
    MicroXRCEAgent udp4 -p 8888
    ```
    The agent and client are now running and they should connect.

# Build & Run ROS 2 Wrokspace
* You can build/run ROS 2 workspace as described [here](https://docs.px4.io/main/en/ros/ros2_comm.html#build-ros-2-workspace)