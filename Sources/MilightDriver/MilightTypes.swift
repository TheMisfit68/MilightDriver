//
//  MilightTypes.swift
//  
//
//  Created by Jan Verrept on 24/10/2019.
//

import Foundation

public enum MilightMode{
    case rgbw
    case white
    case rgb
}

public enum MilightAction{
    case on
    case off
    case allOn
    case allOff
    case nightMode
    case hue
    case whiteMode
    case brightNess
    case brightUp
    case brightDown
    case changeColor
    case saturation
    case warmer
    case cooler
    case speedUp
    case speedDown
    case effectModeNext
    case effectSpeedUp
    case effectSpeedDown
    case link
    case unlink
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
    
    public var mode : MilightMode
    public var action : MilightAction
    public var pattern : [Any]
    public var argumentTransformer:((Any)->UInt8)? = nil
    
    public init(mode:MilightMode, action:MilightAction, pattern:[Any]=[]){
        self.mode = mode
        self.action = action
        self.pattern = pattern
    }
    
}





