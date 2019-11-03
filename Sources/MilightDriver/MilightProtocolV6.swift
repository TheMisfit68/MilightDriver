//
//  MilightProtocolV6.swift
//  
//
//  Created by Jan Verrept on 31/10/2019.
//

import Foundation
//TODO: - Insert color method as an example of a 'recipe'
//TODO: - implement pause between commands


// Use the latest protocoldefinition below as an example for older versions u might need
public struct MilightProtocolV6:MilightProtocol{
    
    public var version:Int = 6
    
    public var commandPort:UInt16 = 5987
    public var responsPort:UInt16 = 58766
    
    public var commands:[[MilightMode: MilightAction] : MilightCommand] = [:]
    
    init(){
        
        // On-Off
        commands.define(mode: .rgbwwcw, action: .on, pattern: [0x31, 0x00, 0x00, 0x08, 0x04, 0x01, 0x00, 0x00, 0x00, MilightVariable.zone])
        commands.define(mode: .rgbwwcw, action: .off, pattern: [0x31, 0x00, 0x00, 0x08, 0x04, 0x02, 0x00, 0x00, 0x00, MilightVariable.zone])
        
        // Color
        commands.define(mode: .rgbwwcw, action: .hue, pattern: [0x31, 0x00, 0x00, 0x08, 0x01, MilightVariable.argument, MilightVariable.argument, MilightVariable.argument, MilightVariable.argument, MilightVariable.zone])
        commands.define(mode: .rgbwwcw, action: .saturation, pattern: [0x31, 0x00, 0x00, 0x08, 0x02, MilightVariable.argument, 0x00, 0x00, 0x00, MilightVariable.zone])
        commands.define(mode: .rgbwwcw, action: .brightNess, pattern: [0x31, 0x00, 0x00, 0x08, 0x03, MilightVariable.argument, 0x00, 0x00, 0x00, MilightVariable.zone])
        
        commands.define(mode: .rgbwwcw, action: .nightMode, pattern: [0x31, 0x00, 0x00, 0x08, 0x04, 0x05, 0x00, 0x00, 0x00, MilightVariable.zone])
        commands.define(mode: .rgbwwcw, action: .temperature, pattern: [0x31, 0x00, 0x00, 0x08, 0x05, MilightVariable.argument, 0x00, 0x00, 0x00, MilightVariable.zone])
        
        // Effects
        commands.define(mode: .rgbwwcw, action: .effect, pattern: [0x31, 0x00, 0x00, 0x08, 0x06, MilightVariable.argument, 0x00, 0x00, 0x00, MilightVariable.zone])
        commands.define(mode: .rgbwwcw, action: .effectSpeedUp, pattern: [0x31, 0x00, 0x00, 0x08, 0x04, 0x03, 0x00, 0x00, 0x00, MilightVariable.zone])
        commands.define(mode: .rgbwwcw, action: .effectSpeedDown, pattern: [0x31, 0x00, 0x00, 0x08, 0x04, 0x04, 0x00, 0x00, 0x00, MilightVariable.zone])
        
        // Linking
        commands.define(mode: .rgbwwcw, action: .link, pattern: [0x3D, 0x00, 0x00, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, MilightVariable.zone])
        commands.define(mode: .rgbwwcw, action: .unlink, pattern: [0x3E, 0x00, 0x00, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, MilightVariable.zone])
        
        
        commands.addArgumentTranformer(mode: .rgbwwcw, action: .hue, {(originalArgument:Any) -> UInt8? in
            // Scale hue between 0°-359°
            guard originalArgument is Int else { return nil }
            let transformedArgument = rescale(value: originalArgument as! Int, inputRange: 0...359, outputRange: 0x0...0xFF)
            return UInt8(transformedArgument)
        })
        
        commands.addArgumentTranformer(mode: .rgbwwcw, action: .saturation, {(originalArgument:Any) -> UInt8? in
            // Limit saturation between 0%-100%
            // 0% on the device is Maximum saturation and vice-versa so also reverse the percentage
            guard originalArgument is Int else { return nil }
            var transformedArgument = originalArgument as! Int
            limit(value: &transformedArgument, toRange:0...100)
            return UInt8(100-transformedArgument)
            
        })
        
        commands.addArgumentTranformer(mode: .rgbwwcw, action: .brightNess, {(originalArgument:Any) -> UInt8? in
            // Limit brightness between 0%-100%
            guard originalArgument is Int else { return nil }
            var transformedArgument = originalArgument as! Int
            limit(value: &transformedArgument, toRange:0...100)
            return UInt8(transformedArgument)
        })
        
        commands.addArgumentTranformer(mode: .rgbwwcw, action: .temperature, {(originalArgument:Any) -> UInt8? in
            // Limit temperature between 0%-100%
            guard originalArgument is Int else { return nil }
            var transformedArgument = originalArgument as! Int
            limit(value: &transformedArgument, toRange:0...100)
            return UInt8(transformedArgument)
        })
        
        commands.addArgumentTranformer(mode: .rgbwwcw, action: .effect, {(originalArgument:Any) -> UInt8? in
            // Limit effectsmode between 1-9
            guard originalArgument is Int else { return nil }
            var transformedArgument = originalArgument as! Int
            limit(value: &transformedArgument, toRange:1...9)
            return UInt8(transformedArgument)
        })
    }
    
    
}
