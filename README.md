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