//
//  MilightProtocolV6.swift
//  
//
//  Created by Jan Verrept on 31/10/2019.
//

import Foundation
import JVCocoa
//TODO: - Insert Color method as an example of a 'recipe'/'combined command'

// Use the latest protocoldefinition below as an example for older versions u might need
public struct MilightProtocolV6:MilightProtocol{
	
	public var version:Int = 6
	
	let searchCommand = "HF-A11ASSISTHREAD"
	let searchPort:UInt16 = 48899
	public let commandPort:UInt16 = 5987
	public let responsPort:UInt16 = 58766
	
	let initializerSequence: MilightDriver.CommandSequence = [0x20,0x00,0x00,0x00,0x16,0x02,0x62,0x3A,0xD5,0xED,0xA3,0x01,0xAE,0x08,0x2D,0x46,0x61,0x41,0xA7,0xF6,0xDC,0xAF,0xD3,0xE6,0x00,0x00,0xC9]
	let intializerResponsPrefix:MilightDriver.ResponseSequence = [0x28,0x00,0x00,0x00,0x11,0x00,0x02]
	
	let commandPrefix: MilightDriver.CommandSequence = [0x80,0x00,0x00,0x00,0x11]
	let commandResponsPrefix: MilightDriver.ResponseSequence = [0x88,0x00,0x00,0x00,0x03]
	
	let keepAliveSequence: MilightDriver.CommandSequence = [0xD0,0x00,0x00,0x00,0x02]
	let keepAliveResponsPrefix: MilightDriver.ResponseSequence = [0xD8,0x00,0x00,0x00,0x07]
	
	public var commands:[[MilightDriver.Mode: MilightDriver.Action] : MilightDriver.Command] = [:]
	public var recipes: [[MilightDriver.Mode : String] : [MilightDriver.Action]] = [:]
	
	public init(){
		
		// On-Off
		commands.define(mode: .rgbwwcw, action: .on, pattern: [0x31, 0x00, 0x00, 0x08, 0x04, 0x01, 0x00, 0x00, 0x00, MilightDriver.Variable.zone])
		commands.define(mode: .rgbwwcw, action: .off, pattern: [0x31, 0x00, 0x00, 0x08, 0x04, 0x02, 0x00, 0x00, 0x00, MilightDriver.Variable.zone])
		
		// White-only mode
		commands.define(mode: .rgbwwcw, action: .whiteOnlyMode, pattern: [0x31, 0x00, 0x00, 0x08, 0x05, 0x64, 0x00, 0x00, 0x00, MilightDriver.Variable.zone])
		
		// Color
		commands.define(mode: .rgbwwcw, action: .hue, pattern: [0x31, 0x00, 0x00, 0x08, 0x01, MilightDriver.Variable.argument, MilightDriver.Variable.argument, MilightDriver.Variable.argument, MilightDriver.Variable.argument, MilightDriver.Variable.zone])
		commands.define(mode: .rgbwwcw, action: .saturation, pattern: [0x31, 0x00, 0x00, 0x08, 0x02, MilightDriver.Variable.argument, 0x00, 0x00, 0x00, MilightDriver.Variable.zone])
		commands.define(mode: .rgbwwcw, action: .brightNess, pattern: [0x31, 0x00, 0x00, 0x08, 0x03, MilightDriver.Variable.argument, 0x00, 0x00, 0x00, MilightDriver.Variable.zone])
		
		commands.define(mode: .rgbwwcw, action: .nightMode, pattern: [0x31, 0x00, 0x00, 0x08, 0x04, 0x05, 0x00, 0x00, 0x00, MilightDriver.Variable.zone])
		commands.define(mode: .rgbwwcw, action: .temperature, pattern: [0x31, 0x00, 0x00, 0x08, 0x05, MilightDriver.Variable.argument, 0x00, 0x00, 0x00, MilightDriver.Variable.zone])
		
		// Effects
		commands.define(mode: .rgbwwcw, action: .effect, pattern: [0x31, 0x00, 0x00, 0x08, 0x06, MilightDriver.Variable.argument, 0x00, 0x00, 0x00, MilightDriver.Variable.zone])
		commands.define(mode: .rgbwwcw, action: .effectSpeedUp, pattern: [0x31, 0x00, 0x00, 0x08, 0x04, 0x03, 0x00, 0x00, 0x00, MilightDriver.Variable.zone])
		commands.define(mode: .rgbwwcw, action: .effectSpeedDown, pattern: [0x31, 0x00, 0x00, 0x08, 0x04, 0x04, 0x00, 0x00, 0x00, MilightDriver.Variable.zone])
		
		// Linking
		commands.define(mode: .rgbwwcw, action: .link, pattern: [0x3D, 0x00, 0x00, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, MilightDriver.Variable.zone])
		commands.define(mode: .rgbwwcw, action: .unlink, pattern: [0x3E, 0x00, 0x00, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, MilightDriver.Variable.zone])
				
		commands.addArgumentTranformer(mode: .rgbwwcw, action: .hue) {(originalArgument:Any) -> UInt8? in
			// Scale hue between 0°-359°
			guard originalArgument is Int else { return nil }
			let transformedArgument = rescale(value: originalArgument as! Int, inputRange: 0...359, outputRange: 0x0...0xFF)
			return UInt8(transformedArgument)
		}
		
		commands.addArgumentTranformer(mode: .rgbwwcw, action: .saturation) {(originalArgument:Any) -> UInt8? in
			// Limit saturation between 0%-100%
			// 0% on the device is Maximum saturation and vice-versa so also reverse the percentage
			guard originalArgument is Int else { return nil }
			var transformedArgument = originalArgument as! Int
			transformedArgument.limitBetween(0...100)
			return UInt8(100-transformedArgument)
			
		}
		
		commands.addArgumentTranformer(mode: .rgbwwcw, action: .brightNess) {(originalArgument:Any) -> UInt8? in
			// Limit brightness between 0%-100%
			guard originalArgument is Int else { return nil }
			var transformedArgument = originalArgument as! Int
			transformedArgument.limitBetween(0...100)
			return UInt8(transformedArgument)
		}
		
		commands.addArgumentTranformer(mode: .rgbwwcw, action: .temperature) {(originalArgument:Any) -> UInt8? in
			// Limit temperature between 0%-100%
			guard originalArgument is Int else { return nil }
			var transformedArgument = originalArgument as! Int
			transformedArgument.limitBetween(0...100)
			return UInt8(transformedArgument)
		}
		
		commands.addArgumentTranformer(mode: .rgbwwcw, action: .effect) {(originalArgument:Any) -> UInt8? in
			// Limit effectsmode between 1-9
			guard originalArgument is Int else { return nil }
			var transformedArgument = originalArgument as! Int
			transformedArgument.limitBetween(1...9)
			return UInt8(transformedArgument)
		}
		
		// Recipes combine multiple actions into a single command
		recipes.define(mode: .rgbwwcw, recipeName: "Color", actions: [.hue, .saturation, .brightNess])
		recipes.define(mode: .rgbwwcw, recipeName: "AllOn", actions: [.on])
		recipes.define(mode: .rgbwwcw, recipeName: "Alloff", actions: [.off]) 
		
	}
	
}

