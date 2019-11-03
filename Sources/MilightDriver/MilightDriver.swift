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
    
    // Respect at least a 50 ms second interval (preferably 75 ms) between commands to prevent execution loss of the command on the Wifii Box.
    var timeStampLastCommand:Date = Date.distantPast
    let inIntervalBetweenCommands:TimeInterval = 0.075
    
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
        let timingNextCommand = Date(timeInterval: inIntervalBetweenCommands, since: timeStampLastCommand)
        while Date() < timingNextCommand {
            usleep(10000) //Wait for 10 ms at the time
        }
        let commandSequence:[UInt8]? = composeCommandSequence(mode: mode, action:action, argument:value, zone:zone)
        if commandSequence != nil{
            commandClient.completionHandler = self.receiveCommandRespons
            let dataToSend = Data(bytes: commandSequence!)
            commandClient.send(data: dataToSend)
        }
        timeStampLastCommand = Date() // Equals Now!
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

func rescale(value: Int, inputRange: ClosedRange<Int>, outputRange: ClosedRange<Int>)->Int{
    var limitedValue =  value
    limit(value: &limitedValue, toRange: inputRange)
    let inputScale = inputRange.upperBound-inputRange.lowerBound
    let outputScale:Float = Float(outputRange.upperBound-outputRange.lowerBound)
    let perecentage:Float = Float(limitedValue-inputRange.lowerBound)/Float(inputScale)
    let rescaledValue:Int = outputRange.lowerBound+Int(perecentage*outputScale)
    return rescaledValue
}

func limit<T:Comparable>(value: inout T, toRange range: ClosedRange<T>){
    value = min(max(value, range.lowerBound), range.upperBound)
}

