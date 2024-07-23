//
//  ViewController.swift
//  NFC Card Reader
//
//  Created by Meet Budheliya on 22/07/24.
//

import UIKit
import CoreNFC

class ViewController: UIViewController, NFCTagReaderSessionDelegate {

    var nfcSession: NFCTagReaderSession?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        startNFCReaderSession()
    }

    @IBAction func BTNScanAction(_ sender: UIButton) {
        startNFCReaderSession()
    }
    
       func startNFCReaderSession() {
           guard NFCTagReaderSession.readingAvailable else {
               print("NFC reading is not supported on this device")
               return
           }
           
           nfcSession = NFCTagReaderSession(pollingOption: .iso14443, delegate: self)
           nfcSession?.alertMessage = "Hold your NFC-enabled credit card near the iPhone."
           nfcSession?.begin()
       }
       
       // MARK: - NFCTagReaderSessionDelegate
       
       func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
           // Session started
       }
       
       func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
           // Session invalidated (e.g., user canceled, tag read error)
       }
       
       func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
           // Handle detected NFC tags
           guard let tag = tags.first else { return }
           
           session.connect(to: tag) { [weak self] (error: Error?) in
                     guard let self = self else { return }
                     
               // Example: Handle ISO 7816 tag (if it's an NFC-enabled credit card)
                          if let iso7816Tag = tag as? NFCISO7816Tag {
                              self.readCreditCardData(from: iso7816Tag)
                          } else {
                              print("Unsupported tag type")
                              session.invalidate(errorMessage: "Unsupported tag type")
                          }
                 }
       }
    
    func readCreditCardData(from tag: NFCISO7816Tag) {
            // Example: Send APDU command to read credit card data
            let apduCommand = NFCISO7816APDU(data: Data([0x00, 0xB2, 0x01, 0x0C, 0x00]))!
            
            tag.sendCommand(apdu: apduCommand) { (responseData, sw1, sw2, error) in
                    let cardData = String(data: responseData, encoding: .utf8)
                    print("Credit card data: \(cardData ?? "Unknown")")
                 
            }
        }
    
    func handleMiFareTag(_ tag: NFCMiFareTag) {
            // Example: Handle MiFare tag operations
            print("MiFare tag detected")
        }
}

