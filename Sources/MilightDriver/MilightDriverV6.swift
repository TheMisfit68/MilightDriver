//  MilightDriverV6.swift
//
//
//  Created by Jan Verrept on 14/10/2019.
//

import Foundation
import Network

@available(OSX 10.14, *)
public class MilightDriverV6: MilightDriver{
    
    let searchPort:UInt16 = 48899
    let searchClient:UDPClient
    let searchCommand = "HF-A11ASSISTHREAD"
    var macAddress:String = ""
    var boxName:String = ""
    
    let initializerSequence: [UInt8] = [0x20,0x00,0x00,0x00,0x16,0x02,0x62,0x3A,0xD5,0xED,0xA3,0x01,0xAE,0x08,0x2D,0x46,0x61,0x41,0xA7,0xF6,0xDC,0xAF,0xD3,0xE6,0x00,0x00,0xC9]  
    
    var currentWifiBridgeSessionIDs:[UInt8]? = nil
    var lastUsedSequenceNumber:UInt8! = nil
    
    var sessionTimer:Timer! = nil
    
    let commandPrefix: [UInt8] = [0x80,0x00,0x00,0x00,0x11]
    let seperator: UInt8 = 0x00
    let defaultArgument:UInt8 = 0x00
    
    public init(ipAddress:String){
        
        searchClient = UDPClient(name: "SearchClient", host: ipAddress, port: searchPort)
        
        let protocolToUse = MilightProtocolV6()
        super.init(milightProtocol: protocolToUse, ipAddress: ipAddress)
        
        sessionTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { timer in self.refreshSessionInfo() }
        sessionTimer.tolerance = 1.0
        
        discoverBridges()
        refreshSessionInfo()
    }
    
    // Search for Wifi Box/ Bridge on the LAN
    public func discoverBridges(){
        searchClient.dataReceiver = self.receiveBridgeInfo
        searchClient.connect()
        let dataToSend=Data(string: searchCommand)
        searchClient.send(data: dataToSend)
    }
    
    
    final override func composeCommandSequence(mode: MilightMode, action:MilightAction, argument: Any?, zone: MilightZone?) -> [UInt8]? {
        var completeSequence:[UInt8]? = nil
        
        let commandeSequence = super.composeCommandSequence(mode: mode, action:action, argument: argument, zone: zone)
        let sequenceNumber = newSequenceNumber
        if (currentWifiBridgeSessionIDs != nil), (commandeSequence != nil){
            let sequenceHeader = commandPrefix+currentWifiBridgeSessionIDs!+[seperator]+[sequenceNumber]+[seperator]
            let sequenceFooter = [seperator]+[checksum(commandeSequence!)]
            completeSequence = sequenceHeader+commandeSequence!+sequenceFooter
        }
        return completeSequence
    }
    
    
    // MARK: - Subroutines
    
    private func refreshSessionInfo(){
        commandClient.dataReceiver = self.receiveSessionInfo
        let dataToSend=Data(bytes: initializerSequence)
        commandClient.send(data: dataToSend)
    }
    
    private var newSequenceNumber:UInt8{
        
        var newSequenceNumber:UInt8
        if let oldSequenceNumber = lastUsedSequenceNumber{
            newSequenceNumber = oldSequenceNumber+1
        }else{
            newSequenceNumber = 0
        }
        lastUsedSequenceNumber = newSequenceNumber
        return newSequenceNumber
    }
    
    private func checksum(_ sequence:[UInt8])->UInt8{
        let arrayOfUInt:[UInt] = Array(sequence[0...9]).map{UInt($0)}
        var checkSum:UInt = arrayOfUInt.reduce(0, +)
        checkSum %= 256
        print("Sequence: \(sequence) witch checsum: \(checkSum)")
        return UInt8(checkSum)
    }
    
    private func receiveBridgeInfo(data:Data?, contentContext:NWConnection.ContentContext?, isComplete:Bool, error:NWError?) -> Void{
        if let data = data, !data.isEmpty {
            let stringRepresentation = String(data: data, encoding: .utf8)
            let client = searchClient
            
            let bridgeInfo:[String] = stringRepresentation!.components(separatedBy: ",")
            if (bridgeInfo.count == 3){
                ipAddress = bridgeInfo[0]
                macAddress = bridgeInfo[1]
                boxName = bridgeInfo[2]
                print("✅\tUDP-connection \(client.name) @IP \(client.host): \(client.port) bridge found:\n" +
                    "\tBridge \(boxName) found @IP \(ipAddress) [MAC \(macAddress)]")
            }
        }
    }
    
    private func receiveSessionInfo(data:Data?, contentContext:NWConnection.ContentContext?, isComplete:Bool, error:NWError?) -> Void{
        if let data = data, !data.isEmpty {
            let stringRepresentation = String(data: data, encoding: .utf8)
            let client = commandClient
            
            currentWifiBridgeSessionIDs = Array(data[19...20])
            if currentWifiBridgeSessionIDs != nil {
                print("ℹ️\tUDP-connection \(client.name) @IP \(client.host): \(client.port) session initiated:\n" +
                    "\t\(Data(bytes:currentWifiBridgeSessionIDs!) as NSData) = string: \(stringRepresentation ?? "''" )")                
            }
        }
    }
}
