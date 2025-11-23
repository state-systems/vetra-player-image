# Kanshi configuration for dual HDMI setup

profile dual_output {
  output *
  output *
  exec sudo systemctl start kiosk-hdmi0.service
  exec sudo systemctl start kiosk-hdmi1.service
}

profile single_output {
  output *
  exec sudo systemctl start kiosk-hdmi0.service
  exec sudo systemctl stop kiosk-hdmi1.service
}

profile no_output {
  exec sudo systemctl start kiosk-hdmi0.service
  exec sudo systemctl stop kiosk-hdmi1.service
}
