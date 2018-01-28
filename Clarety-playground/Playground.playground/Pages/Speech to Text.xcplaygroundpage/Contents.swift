import PlaygroundSupport
import SpeechToTextV1

// Configure playground environment
PlaygroundPage.current.needsIndefiniteExecution = true
URLCache.shared = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)

// Instantiate service
let speechToText = SpeechToText(
    username: Credentials.SpeechToTextUsername,
    password: Credentials.SpeechToTextPassword
)

// Load audio recording
let recordingPath = Bundle.main.path(forResource: "TurnRadioOn", ofType: "wav")!
let recording = URL(fileURLWithPath: recordingPath)

// Transcribe audio recording
let settings = RecognitionSettings(contentType: .wav)
speechToText.recognize(audio: recording, settings: settings) { text in
    print(text.bestTranscript)
}
