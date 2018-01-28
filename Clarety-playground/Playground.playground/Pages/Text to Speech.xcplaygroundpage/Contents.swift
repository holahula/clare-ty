
import PlaygroundSupport
import AVFoundation
import TextToSpeechV1

// Configure playground environment
PlaygroundPage.current.needsIndefiniteExecution = true
URLCache.shared = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)

// Instantiate service
let textToSpeech = TextToSpeech(
    username: Credentials.TextToSpeechUsername,
    password: Credentials.TextToSpeechPassword
)

// Instantiate audio player
var audioPlayer: AVAudioPlayer?

// Synthesize text to spoken word
let text = "Sure thing! Which genre would you prefer? Jazz is my personal favorite."
textToSpeech.synthesize(text) { audio in
    audioPlayer = try! AVAudioPlayer(data: audio)
    audioPlayer?.prepareToPlay()
    audioPlayer?.play()
}
