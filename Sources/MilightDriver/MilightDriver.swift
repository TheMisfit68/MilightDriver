//  MilightDriver.swift
//
//
//  Created by Jan Verrept on 14/10/2019.
//

//AppLamp.nl led light API: wifi box UInt8 commands
//© AppLamp.nl: you can share,modify and use this code (commercially) as long as you
//keep the referer "AppLamp.nl led light API" in the file header.
//RESPECT AT LEAST 50 MS BETWEEN EACH SEND COMMAND TO PREVENT PACKAGE LOSS
//The functions in this file will return the appropriate hex commands as 3 UInt8 array
//to send to an UDP-socket towards WIFI BOX-IP:8899 (see wifibox.js)

import Foundation

public class MilightDriver{
    
    // MARK: - Setup
    
    var ipAddress:String
    var macAdrress:String = ""
    var boxName:String = ""
    
    let milightProtocol:MilightProtocol
    
    let commandClient:UDPclient
    let responsClient:UDPclient
    
    var currentWifiBridgeSessionID:[UInt8]?
    var lastUsedSequenceNumber:UInt8?
    
    let defaultArgument:UInt8 = 0x00
    
    public init(versionNumber:UInt8, ipAddress:String?) {
        
        switch versionNumber {
        case 1:
            milightProtocol=MilightProtocolV1()
        case 2:
            milightProtocol=MilightProtocolV2()
        case 5:
            milightProtocol=MilightProtocolV5()
        default:
            milightProtocol=MilightProtocolV6()
        }
        
        self.ipAddress = ipAddress ?? "255.255.255.255"
        
        commandClient = UDPclient(ipAddress: ipAddress, portNumber: milightProtocol.commandPort)
        responsClient = UDPclient(ipAddress: ipAddress, portNumber: milightProtocol.responsport)
    }
    
    //Search for Wifi Box/ Bridge on the LAN
    public func findBridge(){
        
        if let searchCommand = milightProtocol.searchCommand, let searchPort = milightProtocol.searchPort{
            let searchClient = UDPclient(ipAddress: ipAddress, portNumber: searchPort)
            searchClient.send(string: searchCommand)
            let bridgeInfo:[String] = handleRespons().components(separatedBy:",")
            ipAddress = bridgeInfo[0]
            macAdrress = bridgeInfo[1]
            boxName = bridgeInfo[2]
        }else{
            print("Search not available for protocol version \(milightProtocol.protocolVersion)")
        }
    }
    
    public func refreshSessionInfo(){
        commandClient.send(data: milightProtocol.initializerSequence)
        let sessionInfo:[UInt8] = handleRespons()
        currentWifiBridgeSessionID1 = sessionInfo[19]
        currentWifiBridgeSessionID2 = sessionInfo[20]
    }
    
    // MARK: RGBW
    // RGBW BULBS AND CONTROLLERS, 4-CHANNEL/ZONE MODELS
    
    public func execute(command:MilightCommand, value:UInt8? = nil, zone:MilightZone? = nil){
        
        let commandSequence = milightProtocol.availableCommands[MilightCommand(command)]

        let udpSequence = []
        udpSequence.append(milightProtocol.commandPrefix)
        udpSequence.append(actionSequence)
        
        
        , value:UInt8?, zone:MilightZone?)->[UInt8]?{

            let commandSequence:[UInt8]? = availableCommands[command]
            return commandSequence
        }
        
        var argument = value ?? defaultArgument
        if (command.action == .brightNess) {
            limit(value: &argument, lower: 0, upper: 100)
            argument /= 4
        }
        let commandSequence:[UInt8]? = milightProtocol.composeCommandSequence(command: command, value: value, zone: zone)
        if commandSequence != nil{
            commandClient.send(data: commandSequence!)
            let result:[UInt8] = handleRespons()
        }
        
    }
    
    // MARK: - Subroutines
    
    private var newSequenceNumber:UInt8{
        
        var newSequenceNumber:UInt8
        if let oldSequenceNumber = lastUsedSequenceNumber{
            newSequenceNumber = oldSequenceNumber+1
        }else{
            newSequenceNumber = 0
        }
        return newSequenceNumber
    }
    
    private func handleRespons()->String{
        return responsClient.listen()
    }
    
    private func handleRespons()->[UInt8]{
        return responsClient.listen()
    }
    
    private func limit<T: Comparable>(value: inout T, lower: T, upper: T){
        value =  min(max(value, lower), upper)
    }
    
}

