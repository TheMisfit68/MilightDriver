//
//  MilightProtocol.swift
//  
//
//  Created by Jan Verrept on 02/11/2019.
//

import Foundation

public protocol MilightProtocol{
    
    var version:Int {get}
    
    var commandPort:UInt16 {get}
    var responsPort:UInt16 {get}
    
    var commands:[[MilightMode: MilightAction] : MilightCommand] {get}
    
}
