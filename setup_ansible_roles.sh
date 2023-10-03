#!/bin/bash

# Check if the script is being run from the "sp-automation" folder
if [ "$(basename "$(pwd)")" != "sp-automation" ]; then
    echo "Please run this script from the 'sp-automation' folder."
    exit 1
fi

# Install Ansible requirements
ansible-galaxy install -r roles/requirements.yml

# Create symbolic links for each role for development purposes
ln -sf "$(pwd)/roles/fil_lotus" "$HOME/.ansible/roles/zorlin.fil_lotus"
ln -sf "$(pwd)/roles/lotus_daemon" "$HOME/.ansible/roles/zorlin.lotus_daemon"
ln -sf "$(pwd)/roles/lotus_miner" "$HOME/.ansible/roles/zorlin.lotus_miner"
ln -sf "$(pwd)/roles/lotus_worker" "$HOME/.ansible/roles/zorlin.lotus_worker"
ln -sf "$(pwd)/roles/lotus_boost_actors" "$HOME/.ansible/roles/zorlin.lotus_boost_actors"
ln -sf "$(pwd)/roles/fil_boost" "$HOME/.ansible/roles/zorlin.fil_boost"
ln -sf "$(pwd)/roles/fil_boostd" "$HOME/.ansible/roles/zorlin.fil_boostd"
ln -sf "$(pwd)/roles/fil_booster_http" "$HOME/.ansible/roles/zorlin.fil_booster_http"
ln -sf "$(pwd)/roles/fil_booster_bitswap" "$HOME/.ansible/roles/zorlin.fil_booster_bitswap"
ln -sf "$(pwd)/roles/yugabytedb" "$HOME/.ansible/roles/zorlin.yugabytedb"
