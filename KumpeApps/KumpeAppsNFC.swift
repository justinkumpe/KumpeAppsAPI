//
//  KumpeAppsNFC.swift
//  KumpeApps
//
//  Created by Justin Kumpe on 4/25/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//

import Foundation
import CoreNFC

public class KumpeAppsNFCScan: UIViewController,NFCNDEFReaderSessionDelegate {

        public static let shared = KumpeAppsNFCScan()
    
        //    Parameters
        public struct params {
            public static var nfcMessage:Array< [String : String] > = Array < [String : String] >()
    }
    
    
    public func pressedScan(_ sender: Any) {
        print("pressedScan")
        // 1
        let session = NFCNDEFReaderSession(
            delegate: self,
            queue: nil,
            invalidateAfterFirstRead: true
        )

        // 2
        session.alertMessage = "Hold your device near a tag to scan it."

        // 3
        session.begin()
    }
    
          
    public func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
                print("Started scanning for tags")
            }

           
    public func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        
        print("Detected tags with \(messages.count) messages")
        params.nfcMessage = Array < [String:String] >()
        for messageIndex in 0 ..< messages.count {
            
            let message = messages[messageIndex]
            if #available(iOS 13.0, *) {
                print("\tMessage \(messageIndex) with length \(message.length)")
            } else {
                // Fallback on earlier versions
            }
            
            for recordIndex in 0 ..< message.records.count {
                
                let record = message.records[recordIndex]
                print(record)
                print("\t\tRecord \(recordIndex)")
                print("\t\t\tidentifier: \(String(data: record.identifier, encoding: .utf8)!)")
                print("\t\t\ttype: \(String(data: record.type, encoding: .utf8)!)")
                print("\t\t\tpayload: \(String(data: record.payload, encoding: .utf8)!)")
                
                var nfcData: [String: String] = [:]
                
                nfcData["identifier"] = String(data: record.identifier, encoding: .utf8)
                nfcData["type"] = String(data: record.type, encoding: .utf8)
                nfcData["payload"] = String(data: record.payload, encoding: .utf8)
                
                params.nfcMessage.append(nfcData)
                
            }
        }
    }
            
            
    public func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
                print("Session did invalidate with error: \(error)")
            }

}
