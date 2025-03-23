function fuzzyMatch(str) {
  return str;
}

const routingMatrix = [
  // this hierarchy level is for the audio input devices (hardware audio interfaces or synths)
  {
    id: "L-12",
    match: fuzzyMatch("L-12"),
    unlinkIfPresent: null,
    inputs: [
      {
        id: "L-12 Channel 1",
        match: fuzzyMatch("capture_AUX0"),
        targets: [
          // the targets array should be precedence order. Like, if the first target
          // is available, use it as target, otherwise, try the next one, and so on.
          [fuzzyMatch("Ardour:MIC/audio_in 1")],
          [
            fuzzyMatch("Brave input:input_FL"),
            fuzzyMatch("(Discord|WEBRTC VoiceEngine|Chromium).*input_FL"),
          ],
        ],
      },
    ],
  },
  {
    id: "Scarlett",
    match: fuzzyMatch("Scarlett"),
    unlinkIfPresent: fuzzyMatch("L-12"), // we will unlink the Scarlett in case the L-12 is present
    targets: [
      [fuzzyMatch("Ardour:MIC/audio_in 1")],
      [
        fuzzyMatch("Brave input:input_FL"),
        fuzzyMatch("(Discord|WEBRTC VoiceEngine|Chromium).*input_FL"),
      ],
    ],
  },
];
