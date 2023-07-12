#!/bin/bash

set -x
set -e
shopt -s nullglob

source $HOME/.bashrc > /dev/null 2>&1
source ./variables > /dev/null 2>&1

create_env_file () {
    cat $HOME/.bashrc | grep export | sed "s/^export //" | sudo tee /etc/lotus_env > /dev/null
}

install_systemd_daemon () {
    printf "
[Unit]\n
Description=Lotus Daemon\n
After=network-online.target\n
Requires=network-online.target\n\n

[Service]\n
Environment=GOLOG_FILE=\"$LOG_DIR/lotus.log\"\n
EnvironmentFile=/etc/lotus_env\n
User=$(whoami)\n
Group=$(whoami)\n
ExecStart=/usr/local/bin/lotus daemon\n
Restart=always\n
RestartSec=10\n\n

MemoryAccounting=true\n
MemoryHigh=8G\n
MemoryMax=10G\n
LimitNOFILE=256000:512000\n\n

StandardOutput=append:$LOG_DIR/lotus.log
StandardError=append:$LOG_DIR/lotus.log

[Install]\n
WantedBy=multi-user.target\n
" | sudo tee /etc/systemd/system/lotus-daemon.service > /dev/null

    sudo chmod 0644 /etc/systemd/system/lotus-daemon.service
}

reload_systemd () {
    sudo systemctl daemon-reload
}

stop_services () {
    lotus daemon stop
    sleep 10
}
start_services () {
    sudo systemctl start lotus-daemon
}

enable_services () {
    sudo systemctl enable lotus-daemon
}

create_env_file
install_systemd_daemon
reload_systemd
stop_services
start_services
enable_services