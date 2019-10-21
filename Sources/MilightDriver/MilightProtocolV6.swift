//  MilightProtocolV6.swift
//
//
//  Created by Jan Verrept on 14/10/2019.
//


import Foundation

public struct MilightProtocolV6: MilightProtocol{
    
    public let protocolVersion:UInt8 = 6
    
    public let searchPort: UInt16? = 48899
    
    public let searchCommand:String? = "HF-A11ASSISTHREAD"
    
    public let commandPort: UInt16 = 58766
    
    public let responsport: UInt16 = 5987
    
    public let initializerSequence: [UInt8] = [0x20,0x00,0x00,0x00,0x16,0x02,0x62,0x3A,0xD5,0xED,0xA3,0x01,0xAE,0x08,0x2D,0x46,0x61,0x41,0xA7,0xF6,0xDC,0xAF,0xFE,0xF7,0x00,0x00,0x1E]
    
    public let commandPrefix: [UInt8] = [0x80,0x00,0x00,0x00,0x11]
    
    public let seperator: UInt8 = 0x00
    
    public let terminator:MilightTerminatorType = MilightTerminatorType.checksum
    
    public var availableCommands:[MilightCommand : [UInt8]] = [:]
    
    init(){
            
            availableCommands[MilightCommand(mode: .rgbw, action: .on)] = []
            availableCommands[MilightCommand(mode: .rgbw, action: .off)] = []
            availableCommands[MilightCommand(mode: .rgbw, action: .allOn)] = []
            availableCommands[MilightCommand(mode: .rgbw, action: .allOff)] = []
            availableCommands[MilightCommand(mode: .rgbw, action: .hue)] = []
            availableCommands[MilightCommand(mode: .rgbw, action: .whiteMode)] = []
            availableCommands[MilightCommand(mode: .rgbw, action: .brightNess)] = []
            availableCommands[MilightCommand(mode: .rgbw, action: .effectModeNext)] = []
            availableCommands[MilightCommand(mode: .rgbw, action: .effectSpeedUp)] = []
            availableCommands[MilightCommand(mode: .rgbw, action: .effectSpeedDown)] = []
            
            availableCommands[MilightCommand(mode: .white, action: .on)] = []
            availableCommands[MilightCommand(mode: .white, action: .off)] = []
            availableCommands[MilightCommand(mode: .white, action: .allOn)] = []
            availableCommands[MilightCommand(mode: .white, action: .allOff)] = []
            availableCommands[MilightCommand(mode: .white, action: .nightMode)] = []
            availableCommands[MilightCommand(mode: .white, action: .brightUp)] = []
            availableCommands[MilightCommand(mode: .white, action: .brightDown)] = []
            availableCommands[MilightCommand(mode: .white, action: .warmer)] = []
            availableCommands[MilightCommand(mode: .white, action: .cooler)] = []
            
            availableCommands[MilightCommand(mode: .rgb, action: .on)] = []
            availableCommands[MilightCommand(mode: .rgb, action: .off)] = []
            availableCommands[MilightCommand(mode: .rgb, action: .hue)] = []
            availableCommands[MilightCommand(mode: .rgb, action: .brightUp)] = []
            availableCommands[MilightCommand(mode: .rgb, action: .brightDown)] = []
            availableCommands[MilightCommand(mode: .rgb, action: .speedUp)] = []
            availableCommands[MilightCommand(mode: .rgb, action: .speedDown)] = []
            availableCommands[MilightCommand(mode: .rgb, action: .effectSpeedUp)] = []
            availableCommands[MilightCommand(mode: .rgb, action: .effectSpeedDown)] = []
            
        }
        
}
