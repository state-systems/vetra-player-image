[Unit]
Description=vetra player kiosk app HDMI 0
After=multi-user.target labwc.service kanshi.service network-online.target
Requires=labwc.service kanshi.service
Wants=network-online.target

[Service]
User=<KIOSK_USER>
Environment="XDG_RUNTIME_DIR=<KIOSK_RUNDIR>"
Environment="DISPLAY=:0.0"
Environment="XDG_CONFIG_HOME=<KIOSK_RUNDIR>/.config/hdmi0"
Environment="XDG_CACHE_HOME=<KIOSK_RUNDIR>/.cache/hdmi0"
Restart=always
RestartSec=1
# Wait some time to have a better chance of the network being ready
ExecStartPre=/bin/sleep 3
ExecStart=<KIOSK_APP>
StandardError=journal

[Install]
WantedBy=default.target
