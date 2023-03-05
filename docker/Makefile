.PHONY: px4-dev-base-jammy, px4-dev-simulation-jammy,\
		px4-dev-ros2-humble

all: px4-dev-base-jammy, px4-dev-simulation-jammy,\
		px4-dev-ros2-humble

px4-dev-base-jammy:
	docker build -t mzahana/px4-dev-base-jammy . -f Dockerfile_base-jammy

px4-dev-simulation-jammy: px4-dev-base-jammy
	docker build -t mzahana/px4-dev-simulation-jammy . -f Dockerfile_simulation-jammy

px4-dev-ros2-humble: px4-dev-simulation-jammy
	docker build -t mzahana/px4-dev-ros2-humble . -f Dockerfile_ros2-humble