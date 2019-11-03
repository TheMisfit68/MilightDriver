//
//  MilightProtocolDefinitions.swift
//  
//
//  Created by Jan Verrept on 31/10/2019.
//

import Foundation

public protocol MilightProtocol{
    
    var version:Int {get}
    
    var commandPort:UInt16 {get}
    var responsPort:UInt16 {get}
    
    var commands:[MilightCommand] {get}
    
}


public struct MilightProtocolV6:MilightProtocol{
    
    // RGBWW/CW full color commands

    //poort 58766 naar 5987
    //200000001602623ad5eda301ae082d466141a7f6dcafd3e60000c9
    //
    //respons 22 bytes van 5987 naar 58766
    //28000000110002f0fe6b48e99a12a222d60001860000
    //
    //commando on 22 bytes van 58766 naar 5987
    //8000000011 3e00004200  310000080401000000  01z 00s 3f
    //respons 8 bytes van 5987 naar 58766
    //8800000003004200
    //
    //command of 22 bytes van 58766 naar 5987
    //8000000011pre c300ids 00s 43seq 00s  310000080402000000 01z 00s 40
    //respons 8 bytes van 5987 naar 58766
    //8800000003004300

    //UDP Hex Send Format: 80 00 00 00 11 {WifiBridgeSessionID1} {WifiBridgeSessionID2} 00 {SequenceNumber} 00 {COMMAND} {ZONE NUMBER} 00 {Checksum}
    //format of {command} 9 byte packet = 0x31 {PasswordByte1 default 00} {PasswordByte2 default 00} {remoteStyle 08 for RGBW/WW/CW or 00 for bridge lamp} {LightCommandByte1} {LightCommandByte2} 0x00 0x00 0x00 {Zone1-4 0=All} 0x00 {Checksum}

    
    public var version:Int = 6
    
    public var commandPort:UInt16 = 5987
    public var responsPort:UInt16 = 58766
    
    public var commands:[MilightCommand] = []
    
    init(){
        
        commands.define(mode: .rgbw, action: .on, pattern: [0x31, 0x00, 0x00, 0x08, 0x04, 0x01, 0x00, 0x00, 0x00, MilightVariable.zone])
        commands.define(mode: .rgbw, action: .off, pattern: [0x31, 0x00, 0x00, 0x08, 0x04, 0x02, 0x00, 0x00, 0x00, MilightVariable.zone])
        commands.define(mode: .rgbw, action: .nightMode, pattern: [0x31, 0x00, 0x00, 0x08, 0x04, 0x05, 0x00, 0x00, 0x00, MilightVariable.zone])
        commands.define(mode: .rgbw, action: .whiteMode, pattern: [0x31, 0x00, 0x00, 0x08, 0x05, 0x64, 0x00, 0x00, 0x00, MilightVariable.zone])
        commands.define(mode: .rgbw, action: .brightNess, pattern: [0x31, 0x00, 0x00, 0x08, 0x03, MilightVariable.argument, 0x00, 0x00, 0x00])
        commands.define(mode: .rgbw, action: .effectSpeedDown, pattern: [0x31, 0x00, 0x00, 0x08, 0x05, MilightVariable.argument, 0x00, 0x00, 0x00])
        commands.define(mode: .rgbw, action: .saturation, pattern: [0x31, 0x00, 0x00, 0x08, 0x02, MilightVariable.argument, 0x00, 0x00, 0x00])
        commands.define(mode: .rgbw, action: .effectModeNext, pattern: [0x31, 0x00, 0x00, 0x08, 0x05, MilightVariable.argument, 0x00, 0x00, 0x00])
        commands.define(mode: .rgbw, action: .changeColor, pattern: [0x31, 0x00, 0x00, 0x08, 0x01, MilightVariable.argument, MilightVariable.argument, MilightVariable.argument, MilightVariable.argument])
        
        commands.addArgumentTranformer(mode: .rgbw, action: .on, {(originalArgument:Any) -> UInt8 in
            return originalArgument as! UInt8
        })
    }
    
    
}
