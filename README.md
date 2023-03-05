# px4_ros2_humble
A Docker development environment for PX4 + ROS 2 Humble

# Installation

```bash 
cd px4_ros2_humble/docker
make px4-dev-ros2-humble
```

# Run
```bash
./docker_run.sh
```

**NOTE**

Source files and workspaces are saved inside a shared volume. The path to the shared volume inside the container is `/home/user/shared_volume`. The path to the shared volume in the host is `$HOME/px4_ros2_humble_shared_volume`

# Install PX4
It's recommended to have the PX4-Autopilot src and the ros 2 workspace inside the shared volume, so you don't loose them if the container is removed.

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