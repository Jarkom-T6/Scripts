#!/bin/env bash

# This script is used to make all the nodes ready for usage
# by downloading the setup script from github

# run the script first
curl -Lk 'https://raw.githubusercontent.com/Jarkom-T6/Scripts/master/web_server_ready.sh' | bash

# make it permanent (alias)
echo "alias pull=\"curl -Lk 'https://raw.githubusercontent.com/Jarkom-T6/Scripts/master/web_server_ready.sh' | bash\""
