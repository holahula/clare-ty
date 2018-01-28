import UIKit
import JSQMessagesViewController
import AVFoundation
import ConversationV1
import SpeechToTextV1
import TextToSpeechV1
import PersonalityInsightsV3

class ViewController: JSQMessagesViewController {
    
    @IBOutlet weak var userNameTextField: UITextField!
    
    var messages = [JSQMessage]()
    var incomingBubble: JSQMessagesBubbleImage!
    var outgoingBubble: JSQMessagesBubbleImage!
    
    var conversation: Conversation!
    var speechToText: SpeechToText!
    var textToSpeech: TextToSpeech!
    var personalityInsights: PersonalityInsights!
    
    var audioPlayer: AVAudioPlayer?
    var workspace = Credentials.ConversationWorkspace
    var context: Context?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInterface()
        setupSender()
        setupWatsonServices()
        startConversation()
    }
}

// MARK: Watson Services
extension ViewController {
    
    /// Instantiate the Watson services
    func setupWatsonServices() {
        conversation = Conversation(
            username: Credentials.ConversationUsername,
            password: Credentials.ConversationPassword,
            version: "2017-05-26"
        )
        speechToText = SpeechToText(
            username: Credentials.SpeechToTextUsername,
            password: Credentials.SpeechToTextPassword
        )
        textToSpeech = TextToSpeech(
            username: Credentials.TextToSpeechUsername,
            password: Credentials.TextToSpeechPassword
        )
        personalityInsights = PersonalityInsights(
            username: Credentials.PersonalityInsightsUsername,
            password: Credentials.PersonalityInsightsPassword,
            version: "2018-01-28"
        )
    }
    
    /// Present an error message
    func failure(error: Error) {
        let alert = UIAlertController(
            title: "Watson Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    
    /// Start a new conversation
    func startConversation() {
        conversation.message(
            workspaceID: workspace,
            failure: failure,
            success: presentResponse
        )
    }
    
    /// Present a conversation reply and speak it to the user
    func presentResponse(_ response: MessageResponse) {
        let text = response.output.text.joined()
        context = response.context // save context to continue conversation
        
        // synthesize and speak the response
        textToSpeech.synthesize(text, voice: "en-GB_KateVoice" ,failure: failure) { audio in
            self.audioPlayer = try! AVAudioPlayer(data: audio)
            self.audioPlayer?.prepareToPlay()
            self.audioPlayer?.play()
        }
        // create message
        let message = JSQMessage(
            senderId: User.watson.rawValue,
            displayName: User.getName(User.watson),
            text: text
        )
        // add message to chat window
        if let message = message {
            self.messages.append(message)
            DispatchQueue.main.async { self.finishSendingMessage() }
        }
    }

    /// Start transcribing microphone audio
    @objc func startTranscribing() {
        audioPlayer?.stop()
        var settings = RecognitionSettings(contentType: .opus)
        settings.interimResults = true
        speechToText.recognizeMicrophone(settings: settings, failure: failure) { results in
            self.inputToolbar.contentView.textView.text = results.bestTranscript
            self.inputToolbar.toggleSendButtonEnabled()
        }
    }
    
    /// Stop transcribing microphone audio
    @objc func stopTranscribing() {
        speechToText.stopRecognizeMicrophone()
    }

}

// MARK: Configuration
extension ViewController {
    
    func setupInterface() {
        // bubbles
        let factory = JSQMessagesBubbleImageFactory()
        let incomingColor = UIColor.jsq_messageBubbleLightGray()
        let outgoingColor = UIColor.jsq_messageBubbleGreen()
        incomingBubble = factory!.incomingMessagesBubbleImage(with: incomingColor)
        outgoingBubble = factory!.outgoingMessagesBubbleImage(with: outgoingColor)
        
        // avatars
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        // microphone button
        let microphoneButton = UIButton(type: .custom)
        microphoneButton.setImage(#imageLiteral(resourceName: "microphone-hollow"), for: .normal)
        microphoneButton.setImage(#imageLiteral(resourceName: "microphone"), for: .highlighted)
        microphoneButton.addTarget(self, action: #selector(startTranscribing), for: .touchDown)
        microphoneButton.addTarget(self, action: #selector(stopTranscribing), for: .touchUpInside)
        microphoneButton.addTarget(self, action: #selector(stopTranscribing), for: .touchUpOutside)
        inputToolbar.contentView.leftBarButtonItem = microphoneButton
    }
    
    func setupSender() {
        senderId = User.me.rawValue
        senderDisplayName = User.getName(User.me)
    }
    
    override func didPressSend(
        _ button: UIButton!,
        withMessageText text: String!,
        senderId: String!,
        senderDisplayName: String!,
        date: Date!)
    {
        let message = JSQMessage(
            senderId: User.me.rawValue,
            senderDisplayName: User.getName(User.me),
            date: date,
            text: text
        )
        let failure = { (error: Error) in print(error) }
        personalityInsights.getProfile(fromText: text, failure: failure) { profile in
            dump(profile)
        }
        
        if let message = message {
            self.messages.append(message)
            self.finishSendingMessage(animated: true)
        }
        
        // send text to conversation service
        let input = InputData(text: text)
        let request = MessageRequest(input: input, context: context)
        conversation.message(
            workspaceID: workspace,
            request: request,
            failure: failure,
            success: presentResponse
        )
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        // required by super class
    }
}

// MARK: Collection View Data Source
extension ViewController {
    
    override func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int)
        -> Int
    {
        return messages.count
    }
    
    override func collectionView(
        _ collectionView: JSQMessagesCollectionView!,
        messageDataForItemAt indexPath: IndexPath!)
        -> JSQMessageData!
    {
        return messages[indexPath.item]
    }
    
    override func collectionView(
        _ collectionView: JSQMessagesCollectionView!,
        messageBubbleImageDataForItemAt indexPath: IndexPath!)
        -> JSQMessageBubbleImageDataSource!
    {
        let message = messages[indexPath.item]
        let isOutgoing = (message.senderId == senderId)
        let bubble = (isOutgoing) ? outgoingBubble : incomingBubble
        return bubble
    }
    
    override func collectionView(
        _ collectionView: JSQMessagesCollectionView!,
        avatarImageDataForItemAt indexPath: IndexPath!)
        -> JSQMessageAvatarImageDataSource!
    {
        let message = messages[indexPath.item]
        return User.getAvatar(message.senderId)
    }
    
    override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath)
        -> UICollectionViewCell
    {
        let cell = super.collectionView(
            collectionView,
            cellForItemAt: indexPath
        )
        let jsqCell = cell as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]
        let isOutgoing = (message.senderId == senderId)
        jsqCell.textView.textColor = (isOutgoing) ? .white : .black
        return jsqCell
    }
}
