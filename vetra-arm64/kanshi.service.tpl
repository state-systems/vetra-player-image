[Unit]
Description=kanshi output management
After=labwc.service
Requires=labwc.service
Before=kiosk-hdmi0.service kiosk-hdmi1.service

[Service]
User=<KIOSK_USER>
Environment="XDG_RUNTIME_DIR=<KIOSK_RUNDIR>"
Restart=always
RestartSec=2
ExecStart=/usr/bin/kanshi
StandardError=journal

[Install]
WantedBy=default.target
