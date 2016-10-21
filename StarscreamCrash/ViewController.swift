import UIKit
import Starscream

let invalidPingSeconds = 3.0
let pingTimeInterval = 0.1

class ViewController: UIViewController {
    fileprivate typealias `Self` = ViewController
    
    var socket: WebSocket?
    let protocolName = "protocolName"
    var pingTimer = Timer()
    
    @IBOutlet weak var badUrlTextField: UITextField?
    @IBOutlet weak var goodUrlTextField: UITextField?
    @IBOutlet weak var textView: UITextView?
    
    var invalidUrlString: String { return badUrlTextField?.text ?? "" }
    var validUrlString: String { return goodUrlTextField?.text ?? "" }
    
    @IBAction func startButton_touchUpInside(_ sender: AnyObject) {
        runTest()
    }
    
    @IBAction func stopButton_touchUpInside(_ sender: AnyObject) {
        stopPing()
    }
    
    func runTest() {
        startPing(invalidUrlString)
        
        let _ = Timer.scheduledTimer(withTimeInterval: invalidPingSeconds, repeats: false, block: { _ in
            self.stopPing()
            self.startPing(self.validUrlString)
        })
    }
     
    func startPing(_ urlString: String) {
        stopPing()
        showMessage("startPing(\(urlString)) called")
        self.socket = createWebsocket(urlString)
        
        self.pingTimer = Timer.scheduledTimer(timeInterval: pingTimeInterval, target: self, selector: #selector(Self.pingOnce), userInfo: nil, repeats: true)
    }
    
    func stopPing() {
        showMessage("stopPing() called")
        self.pingTimer.invalidate()
    }
    
    func pingOnce() {
        guard let socket = self.socket else { return }
        
        if !socket.isConnected {
            connectSocket()
        }
        
        showMessage("pinging \(socket.currentURL.absoluteString)")
        socket.write(ping: Data())
    }
    
    func connectSocket() {
        guard let socket = self.socket else {
            showMessage("can't connect: nil socket")
            return
        }
        showMessage("connecting to \(socket.currentURL.absoluteString)")
        socket.connect()
    }
    
    func createWebsocket(_ urlString: String?) -> WebSocket? {
        showMessage("createWebsocket(\(urlString)) called")
        let urlString = urlString ?? ""
        guard let url = URL(string: urlString) else {
            showMessage("could not create url for \(urlString)")
            return nil
        }
        let result = WebSocket(url: url, protocols: [protocolName])
        result.delegate = self
        result.pongDelegate = self
        return result
    }
    
    func showMessage(_ message: String) {
        guard let textView = self.textView else { return }
        textView.text = textView.text + message + "\n"
        let range = NSMakeRange(textView.text.characters.count - 1, 0)
        textView.scrollRangeToVisible(range)
    }
}

extension ViewController: WebSocketDelegate {
    func websocketDidConnect(socket: WebSocket) {
        showMessage("connected to \(socket.urlString)")
    }
    
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        showMessage("disconnected from \(socket.urlString) with error: \(error?.localizedDescription ?? "(none)")")
    }
    
    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        showMessage("received message from \(socket.urlString): \(text)")
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: Data) {
        showMessage("received data from \(socket.urlString)")
    }
}

extension ViewController: WebSocketPongDelegate {
    func websocketDidReceivePong(socket: WebSocket, data: Data?) {
        showMessage("received PONG from \(socket.urlString)")
    }
}

extension WebSocket {
    public var urlString: String {
        return self.currentURL.absoluteString 
    }
}
