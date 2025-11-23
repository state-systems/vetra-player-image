[Unit]
Description=vetra device agent
After=multi-user.target network-online.target
Before=kiosk-hdmi0.service

[Service]
User=<KIOSK_USER>
Environment="XDG_RUNTIME_DIR=<KIOSK_RUNDIR>"
Environment="DISPLAY=:0.0"
Restart=always
RestartSec=5
Environment=RUST_LOG=vetra_device_agent=info
Environment=APPLICATION_URL=<APP_URL>
Environment=JWT_ISSUER=<JWT_ISSUER>
ExecStart=/opt/vetra/device-agent/vetra-device-agent

[Install]
WantedBy=multi-user.target