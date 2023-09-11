//  MilightDriverV6.swift
//
//
//  Created by Jan Verrept on 14/10/2019.
//

import Foundation
import Network
import JVCocoa
import OSLog

public class MilightDriverV6: MilightDriver{
    
    let protocolToUse = MilightProtocolV6()
    let searchClient:UDPClient
    
    var macAddress:String = ""
    var boxName:String = ""
    
    let seperator: UInt8 = 0x00
    let defaultArgument:UInt8 = 0x00
    
    var currentWifiBridgeSessionIDs:[UInt8]? = nil
    var lastUsedSequenceNumber:UInt8! = nil
    
    var sessionTimer:Timer! = nil
    var keepAliveTimer:Timer! = nil
    
    public init(ipAddress:String){
        
        searchClient = UDPClient(name: "SearchClient", host: ipAddress, port: protocolToUse.searchPort)
        searchClient.connect()
        
        super.init(milightProtocol: protocolToUse, ipAddress: ipAddress)
        
        searchClient.dataReceiver = self.receiveBridgeInfo
        commandClient.dataReceiver = self.receiveCommandResponse
        
        discoverBridges()
        refreshSessionInfo()
        
        sessionTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { timer in self.refreshSessionInfo() }
        sessionTimer.tolerance = 1.0
        
        keepAliveTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { timer in self.sendKeepAliveSequence() }
        keepAliveTimer.tolerance = 1.0
    }
    
    final override func composeCommandSequence(mode: Mode, action:Action, argument: Any?, zone: Zone?) -> CommandSequence? {
        var completeSequence:CommandSequence? = nil
        
        let sequenceNumber = newSequenceNumber
        if 	let sessionIDs =  currentWifiBridgeSessionIDs,
            let commandeSequence = super.composeCommandSequence(mode: mode, action:action, argument: argument, zone: zone){
            
            let sequenceHeader = protocolToUse.commandPrefix+sessionIDs+[seperator]+[sequenceNumber]+[seperator]
            let sequenceFooter = [seperator]+[checksum(commandeSequence)]
            completeSequence = sequenceHeader+commandeSequence+sequenceFooter
            
        }
        return completeSequence
    }
    
    
    // MARK: - Sending commands
    
    // Search for Wifi Box/ Bridge on the LAN
    private func discoverBridges(){
        
        let dataToSend = Data(string: protocolToUse.searchCommand)
        searchClient.send(data: dataToSend)
        
    }
    
    private func refreshSessionInfo(){
        
        if commandQueue.isEmpty{
            currentWifiBridgeSessionIDs = nil
            
            let dataToSend = Data(bytes: protocolToUse.initializerSequence)
            commandClient.send(data: dataToSend)
        }
        
    }
    
    private func sendKeepAliveSequence(){
        
        if 	let sessionIDs = currentWifiBridgeSessionIDs{
            
            let dataToSend = Data(bytes: protocolToUse.keepAliveSequence+sessionIDs)
            commandClient.send(data: dataToSend)
            
        }
        
    }
    
    private var newSequenceNumber:UInt8{
        
        var newSequenceNumber:UInt8
        if let oldSequenceNumber = lastUsedSequenceNumber{
            newSequenceNumber = (oldSequenceNumber % 255)+1
        }else{
            newSequenceNumber = 0
        }
        lastUsedSequenceNumber = newSequenceNumber
        return newSequenceNumber
    }
    
    private func checksum(_ sequence:CommandSequence)->UInt8{
        let arrayOfUInt:[UInt] = Array(sequence[0...9]).map{UInt($0)}
        var checkSum:UInt = arrayOfUInt.reduce(0, +)
        checkSum %= 256
        let logger = Logger(subsystem: "be.oneclick.MilightDriver", category: "MilightDriverV6")
        logger.info("Sequence: \(sequence, privacy: .public) witch checsum: \(checkSum, privacy: .public)")
        return UInt8(checkSum)
    }
    
    
    // MARK: - Receiving resoponses
    
    private func receiveBridgeInfo(data:Data?, contentContext:NWConnection.ContentContext?, isComplete:Bool, error:NWError?) -> Void{
        
        if let data = data, !data.isEmpty {
            
            let client = searchClient
            let asciiRepresentation = String(data: data, encoding: .utf8)
            
            if let bridgeInfo:[String] = asciiRepresentation?.components(separatedBy: ","), (bridgeInfo.count == 3){
                ipAddress = bridgeInfo[0]
                macAddress = bridgeInfo[1]
                boxName = bridgeInfo[2]
                
                let logger = Logger(subsystem: "be.oneclick.MilightDriver", category: "MilightDriverV6")
                logger.info("""
                            ✅\tUDP-connection \(client.name, privacy: .public) @IP \(client.hostName, privacy: .public): \(client.portName,privacy: .public) bridge found:
                              \tBridge \(self.boxName, privacy: .public) found @IP \(self.ipAddress, privacy: .public) [MAC \(self.macAddress, privacy: .public)]
                            """)
            }
        }
        
    }
    
    internal override func receiveCommandResponse(data:Data?, contentContext:NWConnection.ContentContext?, isComplete:Bool, error:NWError?) -> Void{
        
        if let data = data, !data.isEmpty {
            
            let client = commandClient
            let response:MilightDriver.ResponseSequence = Array(data)
            let asciiRepresentation = String(data: data, encoding: .utf8)
            
            // Catch and store SessionIDs
            currentWifiBridgeSessionIDs = Array(response[19...20])
            if currentWifiBridgeSessionIDs != nil {
                
                let logger = Logger(subsystem: "be.oneclick.MilightDriver", category: "MilightDriverV6")
                logger.info("UDP-connection \(client.name, privacy: .public) @IP \(client.hostName, privacy: .public): \(client.portName, privacy: .public) session initiated:\t\(Data(bytes:self.currentWifiBridgeSessionIDs!) as NSData, privacy: .public) = string: \(asciiRepresentation ?? "''", privacy: .public)")
            }
        }else{
            super.receiveCommandResponse(data:data, contentContext:contentContext, isComplete:isComplete, error:error)
        }
        
    }
    
    
}

