# Kanshi configuration for dual HDMI setup
# This file will be generated during image build

# Profile for dual HDMI displays
profile dual_hdmi {
  output HDMI-A-1 mode 1920x1080 position 0,0
  output HDMI-A-2 mode 1920x1080 position 1920,0
  exec sudo systemctl start kiosk-hdmi0.service
  exec sudo systemctl start kiosk-hdmi1.service
}

# Fallback profile for single HDMI
profile single_hdmi_1 {
  output HDMI-A-1 mode 1920x1080 position 0,0
  exec sudo systemctl start kiosk-hdmi0.service
  exec sudo systemctl stop kiosk-hdmi1.service
}

profile single_hdmi_2 {
  output HDMI-A-2 mode 1920x1080 position 0,0
  exec sudo systemctl start kiosk-hdmi0.service
  exec sudo systemctl stop kiosk-hdmi1.service
}

# Fallback for any single output
profile single_output {
  output * mode 1920x1080 position 0,0
  exec sudo systemctl start kiosk-hdmi0.service
  exec sudo systemctl stop kiosk-hdmi1.service
}
