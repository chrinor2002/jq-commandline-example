#!/bin/bash

# Given the compose file that has been prepated
# When we start all the services
echo "Starting compose services..."
docker compose up -d
# And we list all the processes for this composition
docker compose ps -a
# Then the db, remote, and local containers are listed
# And remote and db should be running, but local should have exited with 0

# Why did "local" exit?
# It is running a "bash" image. The bash image is just an alpine based image designed to be interactive.
# since the process when starting containers using compose does not allocate a TTY, stdin is immediately
# closed, therefor no input into the bash shell, so bash exits with "success" (AKA exit 0)
