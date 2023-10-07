//
//  MilightTypes.swift
//
//
//  Created by Jan Verrept on 24/10/2019.
//

import Foundation

public extension MilightDriver{
    
    typealias CommandSequence = [UInt8]
    typealias ResponseSequence = [UInt8]
    
    enum Mode{
        case rgbwwcw
        case rgbw
        case white
        case rgb
    }
    
    enum Action{
        
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
        case whiteOnlyMode
        case brightUp
        case brightDown
        case warmer
        case cooler
        
        
    }
    
    enum Variable{
        case zone
        case argument
    }
    
    enum Zone{
        case all
        case zone01(name:String)
        case zone02(name:String)
        case zone03(name:String)
        case zone04(name:String)
        
        var rawValue:UInt8{
            switch self {
            case .zone01:
                0x01
            case .zone02:
                0x02
            case .zone03:
                0x03
            case .zone04:
                0x04
            default:
                0x00
            }
        }
        
        public var name:String{
            switch self {
            case .zone01(let name):
                return name
            case .zone02(let name):
                return name
            case .zone03(let name):
                return name
            case .zone04(let name):
                return name
            default:
                return "all"
            }
        }
    }
    
    struct Command{
        
        public var pattern : [Any]
        public var argumentTransformer:((Any)->UInt8?)? = nil
        
        public init(pattern:[Any]=[]){
            self.pattern = pattern
        }
        
    }
    
}



