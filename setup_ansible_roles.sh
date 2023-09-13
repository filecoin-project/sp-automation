#!/bin/bash

# Check if the script is being run from the "sp-stack-automation" folder
if [ "$(basename "$(pwd)")" != "sp-stack-automation" ]; then
    echo "Please run this script from the 'sp-stack-automation' folder."
    exit 1
fi

# Install Ansible requirements
ansible-galaxy install -r roles/requirements.yml

# Create symbolic links for each role for development purposes
ln -sf "$(pwd)/roles/lotus_daemon" "$HOME/.ansible/roles/zorlin.lotus_daemon"
ln -sf "$(pwd)/roles/lotus_miner" "$HOME/.ansible/roles/zorlin.lotus_miner"
ln -sf "$(pwd)/roles/fil_boost" "$HOME/.ansible/roles/zorlin.fil_boost"
ln -sf "$(pwd)/roles/fil_booster_http" "$HOME/.ansible/roles/zorlin.fil_booster_http"
ln -sf "$(pwd)/roles/yugabytedb" "$HOME/.ansible/roles/zorlin.yugabytedb"
ln -sf "$(pwd)/roles/lotus_boost_actors" "$HOME/.ansible/roles/zorlin.lotus_boost_actors"
