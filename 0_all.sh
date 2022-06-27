#!/bin/bash

# Refer to each file for more details
./bin/reset.sh
./1_what_servers_exist.sh
printf "Press any key to continue" && read -n 1 line && printf "\n"
./2_whats_in_db.sh
printf "Press any key to continue" && read -n 1 line && printf "\n"
./3_cached_ids_simulation.sh
printf "Press any key to continue" && read -n 1 line && printf "\n"
./4_compare_ids.sh
