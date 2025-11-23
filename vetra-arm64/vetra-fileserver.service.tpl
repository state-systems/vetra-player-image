[Unit]
Description=vetra file server
After=multi-user.target
Before=kiosk-hdmi0.service

[Service]
Type=simple
User=root
WorkingDirectory=/opt/vetra/fileserver
ExecStart=/usr/bin/python3 /opt/vetra/fileserver/server.py 8000
Restart=always
RestartSec=5
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
