[Unit]
Description=vetra player kiosk app HDMI 1
After=multi-user.target labwc.service kanshi.service
Requires=labwc.service kanshi.service

[Service]
User=<KIOSK_USER>
Environment="XDG_RUNTIME_DIR=<KIOSK_RUNDIR>"
Environment="DISPLAY=:0.0"
Environment="XDG_CONFIG_HOME=<KIOSK_RUNDIR>/.config/hdmi1"
Environment="XDG_CACHE_HOME=<KIOSK_RUNDIR>/.cache/hdmi1"
Restart=always
RestartSec=5
# Wait for first window to be opened for correct positioning
ExecStartPre=/bin/sleep 5
ExecStart=<KIOSK_APP>
StandardError=journal

[Install]
WantedBy=default.target
