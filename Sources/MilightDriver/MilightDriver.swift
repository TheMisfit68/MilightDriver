//
//  MilightDriver.swift
//  
//
//  Created by Jan Verrept on 20/10/2019.
//

// Abstract Class that can be used as a baseclass to define every Milight protocol out there

import Foundation

@available(macOS 10.14, *)
public class MilightDriver{
    
    // Conform to the MilightProtocol
    internal var protocolDefinition:MilightProtocol
    
    internal var udpClient:UDPClient
    internal var udpServer:UDPServer
    
    init(milightProtocol:MilightProtocol, ipAddress:String){
        
        self.protocolDefinition = milightProtocol
        
        self.udpClient = UDPClient(host: ipAddress, port: protocolDefinition.commandPort)
        self.udpServer = UDPServer(port: protocolDefinition.responsPort)
    }
    
    public func execute(mode:MilightMode,action:MilightAction, value:UInt8? = nil, zone:MilightZone? = nil){
        let commandSequence:[UInt8]? = composeCommandSequence(mode: mode, action:action, argument:value, zone:zone)
        sendSequence(commandSequence)
    }
    
    internal func sendSequence(_ sequence:[UInt8]?){
        var sequenceToSend = sequence
        if sequenceToSend != nil{
            let dataToSend:Data = Data(bytes: &sequenceToSend!, count: sequenceToSend!.count)
            udpClient.send(data: dataToSend)
        }
    }
    
    internal func composeCommandSequence(mode: MilightMode, action:MilightAction, argument: UInt8?, zone: MilightZone?) -> [UInt8]? {
        
        var commandSequence:[UInt8]? = nil
        let zoneNumber:Int = (zone != nil) ? Int(zone!.rawValue) : 0x00
        let command = protocolDefinition.commands[mode, action]
        
        if let commandPattern:[Any] = command?.pattern{
            
            commandSequence = commandPattern.compactMap{ pattern in
                
                switch pattern {
                case let hexValue as Int:
                    return UInt8(hexValue)
                case let multipleHexValues as [Int]:
                    let zoneIndex:Int = Int(zoneNumber)
                    let hexValue = multipleHexValues[zoneIndex]
                    return UInt8(hexValue)
                case is MilightVariable:
                    if (argument != nil){
                        if let argumentTransformer = command?.argumentTransformer{
                            return argumentTransformer(argument!)
                        }else{
                            return UInt8(argument!)
                        }
                    }else{
                        return nil  // Shorten the sequence, so it will not be processed any further
                    }
                default:
                    return nil // Shorten the sequence, so it will not be processed any further
                }
            }
            if (commandPattern.count != commandSequence!.count){
                print("🛑:\t Malformed commandsequence: \(String(describing: commandSequence)) ")
                commandSequence = nil
            }
            
        }else{
            print("🛑:\t Undefined command: \(String(describing: command)) ")
        }
        return commandSequence
    }
    
    
    
    internal func limit<T: Comparable>(value: inout T, lower: T, upper: T){
        value =  min(max(value, lower), upper)
    }
    
    
}

// MARK: - Helper for Array of MilightCommand

extension Array where Element == MilightCommand {
    
    // Use this extension so that the Array of MilightCommands can be subscripted with a pair of Enums (MilightMode and MilightAction)
    // (because normal tuples are not hashable)
    
    subscript(mode:MilightMode, action:MilightAction) -> MilightCommand? {
        
        get{
            return self.first(where: { $0.mode == mode && $0.action == action })
        }
        
        set{
            self.removeAll(where: { $0.mode == mode && $0.action == action })
            self.append(newValue!)
        }
        
    }
    
    public mutating func define(mode:MilightMode, action:MilightAction, pattern:[Any]){
        self[mode, action] = MilightCommand(mode: mode, action: action, pattern: pattern)
    }
    
    public mutating func addArgumentTranformer(mode:MilightMode, action:MilightAction, _ argumentTransformer:@escaping (Any)->UInt8){
        if var command = self[mode, action] {
            command.argumentTransformer = argumentTransformer
            self[mode, action] = command
        }
    }
    
}
