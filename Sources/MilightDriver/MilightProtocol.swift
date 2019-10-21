//
//  MilightProtocol..swift
//  
//
//  Created by Jan Verrept on 20/10/2019.
//

import Foundation

public protocol MilightProtocol {
    
    var protocolVersion:UInt8 { get }
    
    var searchPort:UInt16? { get }
    var searchCommand:String?{ get }
    
    var commandPort:UInt16{ get }
    var responsport:UInt16{ get }
    
    var initializerSequence:[UInt8]{ get }
    var commandPrefix:[UInt8]{ get }
    var seperator:UInt8{ get }
    var terminator:MilightTerminatorType{ get }
    
    var availableCommands:[MilightCommand: [UInt8]] {get}
    
    func composeCommandSequence(command: MilightCommand, value:UInt8?, zone:MilightZone?)->[UInt8]?
    
}

public struct MilightCommand:Hashable{
    var mode : MilightMode? = nil
    var action : MilightAction? = nil
}
