//
//  MilightTypes.swift
//  
//
//  Created by Jan Verrept on 24/10/2019.
//

import Foundation

public enum MilightMode{
    case rgbwwcw
    case rgbw
    case white
    case rgb
}

public enum MilightAction{
    
    // On-Off
    case on //OK •
    case off //OK •
    
    // Color
    case hue // ??-???•
    case saturation //OK • in % 0x00MAx to 0x64MIN
    case brightNess //OK in % • 0x00 to 0x64
    case nightMode //OK •
    case temperature //OK in % • // temperature values 0x00 to 0x64 : examples: 00 = 2700K (Warm White), 19 = 3650K, 32 = 4600K, 4B, = 5550K, 64 = 6500K (Cool White)
    
    // Effects
    case mode //OK • 1 tot 9
    case effectSpeedUp //OK •
    case effectSpeedDown //OK •
    
    // Linking
    case link //OK •
    case unlink //OK •
    
    // White only commands
    case brightUp
    case brightDown
    case warmer
    case cooler
  
    
}

public enum MilightVariable{
    case zone
    case argument
}


public enum MilightZone:UInt8{
    case all
    case zone01
    case zone02
    case zone03
    case zone04
}

public struct MilightCommand{
    
    public var pattern : [Any]
    public var argumentTransformer:((Any)->UInt8?)? = nil
    
    public init(pattern:[Any]=[]){
        self.pattern = pattern
    }
    
}





