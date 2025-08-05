[Unit]
Description=vetra player kiosk app HDMI 1
After=multi-user.target labwc.service kanshi.service
Requires=labwc.service kanshi.service

[Service]
User=<KIOSK_USER>
Environment="XDG_RUNTIME_DIR=<KIOSK_RUNDIR>"
Environment="DISPLAY=:0.0"
Restart=always
RestartSec=5
# Wait for displays to be configured
ExecStartPre=/bin/sleep 3
ExecStart=<KIOSK_APP> --profile-name hdmi2
StandardError=journal
[Install]
WantedBy=default.target
