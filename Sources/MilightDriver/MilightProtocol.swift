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
    var recipes:[[MilightMode: String] : [MilightAction]] {get}
    
}


// MARK: - Extensions

extension Dictionary where Key == [MilightMode : MilightAction] ,  Value == MilightCommand {
    
    public mutating func define(mode:MilightMode, action:MilightAction, pattern:[Any]){
        self[[mode : action]] = MilightCommand(pattern: pattern)
    }
    
    public mutating func addArgumentTranformer(mode:MilightMode, action:MilightAction, _ argumentTransformer:@escaping (Any)->UInt8?){
        if var command:MilightCommand = self[[mode : action]]{
            command.argumentTransformer = argumentTransformer
            self[[mode : action]] = command
        }
    }
    
}

extension Dictionary where Key == [MilightMode : String] ,  Value == [MilightAction] {
    
    public mutating func define(mode:MilightMode, recipeName:String, actions:[MilightAction]){
        self[[mode : recipeName]] = actions
    }
    
    public mutating func addArgumentTranformer(mode:MilightMode, recipeName:MilightAction, _ argumentTransformer:@escaping (Any)->[UInt8?]){
//        if var command:MilightCommand = self[[mode : action]]{
//            command.argumentTransformer = argumentTransformer
//            self[[mode : action]] = command
//        }
    }
    
}

