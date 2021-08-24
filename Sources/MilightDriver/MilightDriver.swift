//
//  MilightDriver.swift
//  
//
//  Created by Jan Verrept on 20/10/2019.
//

// Abstract Class that can be used as a baseclass to define every Milight protocol out there

import Foundation
import Network
import JVCocoa

public class MilightDriver{
	
	// Conform to the MilightProtocol
	var protocolDefinition:MilightProtocol
	
	var ipAddress:String
	var commandClient:UDPClient
	
	// Respect at least a 50 ms second interval (preferably 75 ms) between commands to prevent execution loss of the command on the Wifii Box.
	let inIntervalBetweenCommands:TimeInterval = 0.075
	var commandQueueTimer:Timer!
	var commandQueue:[[UInt8]] = []
		
	public init(milightProtocol:MilightProtocol, ipAddress:String){
		
		self.protocolDefinition = milightProtocol
		self.ipAddress = ipAddress
		self.commandClient = UDPClient(name: "CommandClient", host: ipAddress, port: protocolDefinition.commandPort)
		self.commandClient.dataReceiver = receiveCommandRespons
		self.commandClient.connect()
		
		commandQueueTimer = Timer.scheduledTimer(withTimeInterval: inIntervalBetweenCommands, repeats: true) { timer in self.sendNextCommand() }
		commandQueueTimer.tolerance = commandQueueTimer.timeInterval/10.0 // Give the processor some slack with a 10% tolerance on the timeInterval
	}
	
	deinit {
		// perform the deinitialization
		commandQueueTimer.invalidate()
		self.commandClient.disconnect()
	}
	
	public func executeCommand(mode:Mode,action:Action, value:Any? = nil, zone:Zone? = nil){
		if let commandSequence = composeCommandSequence(mode: mode, action:action, argument:value, zone:zone){
			commandQueue.append(commandSequence)
		}
	}
	
	
	// MARK: - Subroutines
	private func sendNextCommand(){
		
		if commandQueue.count > 0{
			let  commandSequence = commandQueue.first
			commandClient.dataReceiver = self.receiveCommandRespons
			let dataToSend = Data(bytes: commandSequence!)
			commandClient.send(data: dataToSend)
			commandQueue.removeFirst(1)
		}
		
	}
	
	
	internal func composeCommandSequence(mode: Mode, action:Action, argument: Any?, zone: Zone?) -> [UInt8]? {
		
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
					case Variable.argument:
						
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
						
					case Variable.zone:
						return UInt8(zoneNumber)
					case Zone.all:
						return UInt8(Zone.all.rawValue)
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
	
	private func receiveCommandRespons(data:Data?, contentContext:NWConnection.ContentContext?, isComplete:Bool, error:NWError?) -> Void{
		// Never process the respons other then printing it to the console
		if let data = data, !data.isEmpty {
			let stringRepresentation = String(data: data, encoding: .utf8)
			let client = commandClient
			print("ℹ️\tUDP-connection \(client.name) @IP \(client.host): \(client.port) received respons:\n" +
					"\t\(data as NSData) = string: \(stringRepresentation ?? "''" )")
		}
		
	}
	
}
