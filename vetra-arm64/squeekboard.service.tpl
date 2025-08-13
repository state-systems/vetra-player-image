[Unit]
Description=squeekboard virtual keyboard
After=labwc.service
Requires=labwc.service

[Service]
TTYPath=/dev/tty1
Environment="XDG_RUNTIME_DIR=<KIOSK_RUNDIR>"
Environment="XDG_DATA_DIRS=/usr/local/share:/usr/share"
Environment="GTK_THEME=Adwaita-dark"
Environment="DISPLAY=:0"
Restart=always
RestartSec=2
ExecStart=squeekboard
StandardError=journal

[Install]
WantedBy=default.target
