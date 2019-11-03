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
    case on
    case off
    
    // Color
    case hue
    case saturation
    case brightNess
    case nightMode
    case temperature
    
    // Effects
    case effect
    case effectSpeedUp
    case effectSpeedDown
    
    // Linking
    case link
    case unlink
    
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





