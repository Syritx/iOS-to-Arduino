//
//  ViewController.swift
//  swift-sockets
//
//  Created by Syritx on 2021-01-21.
//

import UIKit
import Foundation

class ViewController: UIViewController {
    
    var readStream : Unmanaged<CFReadStream>?
    var writeStream : Unmanaged<CFWriteStream>?
    
    var inputStream : InputStream!
    var outputStream : OutputStream!
    
    var HOST : NSString?
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        HOST = "HOST"
        let uiView = UIView()
        uiView.backgroundColor = .black
        
        let width = UIScreen.main.bounds.width-40
        let yOffset = 20
        let inlineOffset = 10
        
        let messageButton = UIButton()
        messageButton.frame = CGRect(x: 20, y: 20+yOffset+inlineOffset, width: Int(width), height: 50)
        messageButton.setTitle("Request Data", for: .normal)
        messageButton.backgroundColor = .link
        messageButton.setTitleColor(.white, for: .normal)
        messageButton.addTarget(self, action: #selector(requestDataFromServer(_:)), for: .touchUpInside)
        
        let disconnect = UIButton()
        disconnect.frame = CGRect(x: 20, y: 120+yOffset+inlineOffset*3, width: Int(width), height: 50)
        disconnect.setTitle("Disconnect", for: .normal)
        disconnect.backgroundColor = .link
        disconnect.setTitleColor(.white, for: .normal)
        disconnect.addTarget(self, action: #selector(disconnectFromServer(_:)), for: .touchUpInside)
        
        let connect = UIButton()
        connect.frame = CGRect(x: 20, y: 70+yOffset+inlineOffset*2, width: Int(width), height: 50)
        connect.setTitle("Connect", for: .normal)
        connect.backgroundColor = .link
        connect.setTitleColor(.white, for: .normal)
        connect.addTarget(self, action: #selector(connectToServer(_:)), for: .touchUpInside)
        
        self.view = uiView
        view.addSubview(messageButton)
        view.addSubview(disconnect)
        view.addSubview(connect)
        view.addSubview(temperatureLabel)
        view.addSubview(humidityLabel)
    }
    
    @objc func requestDataFromServer(_ sender: UIButton) {
        
        let dat = "led".data(using: .utf8)!
        
        dat.withUnsafeBytes {
            guard let pointer = $0.baseAddress?.assumingMemoryBound(to: UInt8.self)
            else {
                return
            }
            outputStream!.write(pointer, maxLength: dat.count)
        }
    }
    
    @objc func connectToServer(_ sender: UIButton) {
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, HOST, 6020, &readStream, &writeStream)
        inputStream = readStream!.takeRetainedValue()
        outputStream = writeStream!.takeRetainedValue()
        
        inputStream.delegate = self
        inputStream.schedule(in: .current, forMode: .common)
        outputStream.schedule(in: .current, forMode: .common)
        inputStream.open()
        outputStream.open()
    }
    
    @objc func disconnectFromServer(_ sender: UIButton) {
        let dat = "disconnected".data(using: .utf8)!
        
        dat.withUnsafeBytes {
            guard let pointer = $0.baseAddress?.assumingMemoryBound(to: UInt8.self)
            else {
                return
            }
            outputStream!.write(pointer, maxLength: dat.count)
        }
        outputStream!.close()
    }
}

extension ViewController : StreamDelegate {
    
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        
        switch eventCode {
            
        case .hasBytesAvailable:
            print("message")
            getReceivedMessage(stream: aStream as! InputStream)
            
        default:
            print("other events")
        }
    }
    
    func getReceivedMessage(stream: InputStream) {
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 1024)
        var totalLength = 0
        
        while stream.hasBytesAvailable {
            let len = stream.read(buffer, maxLength: 1024)
            if len < 0, let error = stream.streamError {
                print(error)
                break
            }
            print("test")
            totalLength = len
            break
        }
        
        print("length has a greater value than 0");
        guard let output = String(bytesNoCopy: buffer,
                            length: totalLength,
                            encoding: .utf8,
                            freeWhenDone: true)
        else {
            return
        }
        print(totalLength)
    }
}
