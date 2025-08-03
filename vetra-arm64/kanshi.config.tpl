# Kanshi configuration for dual HDMI setup
# This file will be generated during image build

# Profile for dual 4K displays
profile dual_4k {
  output HDMI-A-1 mode 3840x2160 position 0,0
  output HDMI-A-2 mode 3840x2160 position 3840,0
  exec sudo systemctl start kiosk-hdmi0.service
  exec sudo systemctl start kiosk-hdmi1.service
}

# Profile for dual Full HD displays
profile dual_hdmi {
  output HDMI-A-1 mode 1920x1080 position 0,0
  output HDMI-A-2 mode 1920x1080 position 1920,0
  exec sudo systemctl start kiosk-hdmi0.service
  exec sudo systemctl start kiosk-hdmi1.service
}

# Fallback profiles for single 4K displays
profile single_4k_1 {
  output HDMI-A-1 mode 3840x2160 position 0,0
  exec sudo systemctl start kiosk-hdmi0.service
  exec sudo systemctl stop kiosk-hdmi1.service
}

profile single_4k_2 {
  output HDMI-A-2 mode 3840x2160 position 0,0
  exec sudo systemctl start kiosk-hdmi0.service
  exec sudo systemctl stop kiosk-hdmi1.service
}

# Fallback profiles for single Full HD displays
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

# Generic fallback profiles for any single output
profile single_output_4k {
  output * mode 3840x2160 position 0,0
  exec sudo systemctl start kiosk-hdmi0.service
  exec sudo systemctl stop kiosk-hdmi1.service
}

# Fallback for any single output (Full HD)
profile single_output {
  output * mode 1920x1080 position 0,0
  exec sudo systemctl start kiosk-hdmi0.service
  exec sudo systemctl stop kiosk-hdmi1.service
}
