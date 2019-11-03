//
//  MilightDriver.swift
//  
//
//  Created by Jan Verrept on 20/10/2019.
//

// Abstract Class that can be used as a baseclass to define every Milight protocol out there

import Foundation
import Network

@available(macOS 10.14, *)
public class MilightDriver{
    
    // Conform to the MilightProtocol
    var protocolDefinition:MilightProtocol
    
    var ipAddress:String
    var commandClient:UDPClient
    
    init(milightProtocol:MilightProtocol, ipAddress:String){
        
        self.protocolDefinition = milightProtocol
        self.ipAddress = ipAddress
        self.commandClient = UDPClient(name: "CommandClient", host: ipAddress, port: protocolDefinition.commandPort)
        self.commandClient.completionHandler = receiveCommandRespons
        self.commandClient.connect()
    }
    
    deinit {
        // perform the deinitialization
        self.commandClient.disconnect()
    }
    
    public func executeCommand(mode:MilightMode,action:MilightAction, value:Any? = nil, zone:MilightZone? = nil){
        let commandSequence:[UInt8]? = composeCommandSequence(mode: mode, action:action, argument:value, zone:zone)
        if commandSequence != nil{
            commandClient.completionHandler = self.receiveCommandRespons
            let dataToSend = Data(bytes: commandSequence!)
            commandClient.send(data: dataToSend)
        }
    }
    
    
    // MARK: - Subroutines
    func composeCommandSequence(mode: MilightMode, action:MilightAction, argument: Any?, zone: MilightZone?) -> [UInt8]? {
        
        var commandSequence:[UInt8]? = nil
        let zoneNumber:Int = (zone != nil) ? Int(zone!.rawValue) : 0x00
        let command = protocolDefinition.commands[[mode : action]]
        
        if let commandPattern:[Any] = command?.pattern{
            
            commandSequence = commandPattern.compactMap{ pattern in
                
                switch pattern {
                case let hexValue as Int:
                    return UInt8(hexValue)
                case let multipleHexValues as [Int]:
                    let zoneIndex:Int = Int(zoneNumber)
                    let hexValue = multipleHexValues[zoneIndex]
                    return UInt8(hexValue)
                case MilightVariable.argument:
                    
                    // Parse the argument-parameter
//FIXME: - <#name#>
//FIXME: - <#name#>
//FIXME: - <#name#>
//FIXME: - <#name#>
//FIXME: - <#name#>
//FIXME: - <#name#>
//FIXME: - <#name#>
//FIXME: - <#name#>
                    if (argument != nil){
                        if let argumentTransformer = command?.argumentTransformer{
                            return argumentTransformer(argument!)
                        }else if let originalValue = argument as? UInt8 {
                            return originalValue
                        }else{
                            return nil
                        }
                    }else{
                        return nil
                    }
                    
                case MilightVariable.zone:
                    return UInt8(zoneNumber)
                case MilightZone.all:
                    return UInt8(MilightZone.all.rawValue)
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
    
    func receiveCommandRespons(data:Data?, contentContext:NWConnection.ContentContext?, isComplete:Bool, error:NWError?) -> Void{
        if let data = data, !data.isEmpty {
            let stringRepresentation = String(data: data, encoding: .utf8)
            let client = commandClient
            print("ℹ️\tUDP-connection \(client.name) @IP \(client.host): \(client.port) received respons:\n" +
                "\t\(data as NSData) = string: \(stringRepresentation ?? "''" )")
        }
        if isComplete {
            //                    self.connectionDidEnd()
        } else if let error = error {
//TODO: - clean up this error handling that was in the UDP-client before

            //                    self.connectionDidFail(error: error)
        } else {
            //                    self.prepareReceive()
        }
    }
    
}



// MARK: - Extensions

extension Dictionary where Key == [MilightMode : MilightAction] ,  Value == MilightCommand {
    
    public mutating func define(mode:MilightMode, action:MilightAction, pattern:[Any]){
        self[[mode : action]] = MilightCommand(pattern: pattern)
    }
    
    public mutating func addArgumentTranformer(mode:MilightMode, action:MilightAction, _ argumentTransformer:@escaping (Any)->UInt8?){
        if var command:MilightCommand = self[[mode : action]]{
            command.argumentTransformer = argumentTransformer
            self[[mode : action]] = command
        }
    }
    
}

extension Data{
    
    init(string:String){
        var stringAsBytes:[UInt8] = Array(string.utf8)
        self.init(bytes: &stringAsBytes, count: stringAsBytes.count)
    }
    
    init(bytes:[UInt8]){
        var numberOfBytes:[UInt8] = bytes
        self.init(bytes: &numberOfBytes, count: numberOfBytes.count)
    }
    
}

func rescale(value: Int, lower: Int, upper: Int)->UInt8?{
    let limitedValue:Int = min(max(value, lower),upper)
    let perecentage:Float = Float(limitedValue-lower)/Float(upper-lower)
    let maxOutput:Float = Float(UInt8.max)
    let scaledValue:UInt8? = UInt8(lower+Int(perecentage*maxOutput))
    return scaledValue
}

func limit(value: Int, lower: Int, upper: Int)->UInt8?{
    let limitedValue =  min(max(value, lower), upper)
    return  UInt8(limitedValue)
}

