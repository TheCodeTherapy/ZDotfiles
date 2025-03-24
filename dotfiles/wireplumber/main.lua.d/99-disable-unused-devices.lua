-- Disable unwanted devices based on their description
table.insert(alsa_monitor.rules, {
  matches = {
    { { "node.description", "matches", "USB Audio Front Headphones" } },
    { { "node.description", "matches", "USB Audio Speakers" } },
    { { "node.description", "matches", "USB Audio S/PDIF Out" } },
    { { "node.description", "matches", "USB Audio Line In" } },
    { { "node.description", "matches", "USB Audio Microphone" } },
    { { "node.description", "matches", "USB Audio Front Microphone" } },
    { { "node.description", "matches", "AD102 High Definition Audio Controller Digital Stereo (HDMI)" } },
  },
  apply_properties = {
    ["device.disabled"] = true
  }
})

table.insert(alsa_monitor.rules, {
  matches = {
    { { "device.name", "matches", "alsa_card.usb-Sony_ZV-1_C7F6A02C734E-02" } }
  },
  apply_properties = {
    ["device.disabled"] = true
  }
})
