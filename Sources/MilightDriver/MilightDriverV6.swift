//  MilightDriverV6.swift
//
//
//  Created by Jan Verrept on 14/10/2019.
//

import Foundation

@available(OSX 10.14, *)
public class MilightDriverV6: MilightDriver{
    
    let searchPort = 48899
    let searchCommand = "HF-A11ASSISTHREAD"
    var macAddress:String = ""
    var boxName:String = ""
    
    let initializerSequence: [UInt8] = [0x20,0x00,0x00,0x00,0x16,0x02,0x62,0x3A,0xD5,0xED,0xA3,0x01,0xAE,0x08,0x2D,0x46,0x61,0x41,0xA7,0xF6,0xDC,0xAF,0xFE,0xF7,0x00,0x00,0x1E]
    var currentWifiBridgeSessionIDs:[UInt8]? = nil
    var lastUsedSequenceNumber:UInt8! = nil
    
    var sessionTimer:Timer! = nil
    
    let commandPrefix: [UInt8] = [0x80,0x00,0x00,0x00,0x11]
    let seperator: UInt8 = 0x00
    let defaultArgument:UInt8 = 0x00
    
    init(ipAddress:String){
        
        let protocolToUse = MilightProtocolV6()
        super.init(milightProtocol: protocolToUse, ipAddress: ipAddress)
        
        sessionTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { timer in self.refreshSessionInfo() }
        sessionTimer.tolerance = 1.0
    }
    
    // Search for Wifi Box/ Bridge on the LAN
    public func discoverBridges(){
        let searchSequence:[UInt8] = Array(searchCommand.utf8)
        sendSequence(searchSequence)
        //        let bridgeInfo:[String] = handleRespons().components(separatedBy:",")
        //        ipAddress = bridgeInfo[0]
        //        macAddress = bridgeInfo[1]
        //        boxName = bridgeInfo[2]
        
    }
    
    
    final override func composeCommandSequence(mode: MilightMode, action:MilightAction, argument: UInt8?, zone: MilightZone?) -> [UInt8]? {
        var completeSequence:[UInt8]? = nil
        
        let commandeSequence = super.composeCommandSequence(mode: mode, action:action, argument: argument, zone: zone)
        if commandeSequence != nil {
            let sequenceHeader = commandPrefix+[seperator]+[seperator]+[seperator]
            let sequenceFooter = [seperator]+[checksum(commandeSequence!)]
            completeSequence = sequenceHeader+commandeSequence!+sequenceFooter
        }
        return completeSequence
    }
    
    
    // MARK: - Subroutines
    
    private func refreshSessionInfo(){
        sendSequence(initializerSequence)
        //            let sessionInfo:[UInt8] = handleRespons()
        //            currentWifiBridgeSessionIDs = Array(sessionInfo[19...20])
        
    }
    
    private var newSequenceNumber:UInt8{
        
        var newSequenceNumber:UInt8
        if let oldSequenceNumber = lastUsedSequenceNumber{
            newSequenceNumber = oldSequenceNumber+1
        }else{
            newSequenceNumber = 0
        }
        return newSequenceNumber
    }
    
    private func checksum(_ sequence:[UInt8])->UInt8{
        return Array(sequence[0...9]).reduce(0, +)
    }
    
}
