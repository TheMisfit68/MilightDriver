//
//  MilightTypes.swift
//  
//
//  Created by Jan Verrept on 16/10/2019.
//

import Foundation

// MARK: Main Types
public enum MilightMode{
    case rgbw
    case white
    case rgb
}

// MARK: RGBW
// RGBW BULBS AND CONTROLLERS, 4-CHANNEL/ZONE MODELS
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
    case warmer
    case cooler
    case speedUp
    case speedDown
    case effectModeNext
    case effectSpeedUp
    case effectSpeedDown
}


public enum MilightZone:Int{
    case all
    case Zone01
    case Zone02
    case Zone03
    case Zone04
}

public enum MilightTerminatorType{
    case constant(UInt8)
    case checksum
}

