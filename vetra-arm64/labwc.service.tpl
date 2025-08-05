[Unit]
Description=labwc wayland compositor
After=multi-user.target
Before=kanshi.service kiosk-hdmi0.service kiosk-hdmi1.service

[Service]
User=<KIOSK_USER>
TTYPath=/dev/tty1
Environment="XDG_RUNTIME_DIR=<KIOSK_RUNDIR>"
Restart=always
RestartSec=2
ExecStart=/usr/bin/labwc
StandardError=journal

[Install]
WantedBy=default.target
