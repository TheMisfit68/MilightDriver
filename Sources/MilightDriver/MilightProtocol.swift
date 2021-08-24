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
    
	var commands:[[MilightDriver.Mode: MilightDriver.Action] : MilightDriver.Command] {get}
	var recipes:[[MilightDriver.Mode: String] : [MilightDriver.Action]] {get}
    
}


// MARK: - Extensions

extension Dictionary where Key == [MilightDriver.Mode : MilightDriver.Action] ,  Value == MilightDriver.Command {
    
	public mutating func define(mode:MilightDriver.Mode, action:MilightDriver.Action, pattern:[Any]){
		self[[mode : action]] = MilightDriver.Command(pattern: pattern)
    }
    
	public mutating func addArgumentTranformer(mode:MilightDriver.Mode, action:MilightDriver.Action, _ argumentTransformer:@escaping (Any)->UInt8?){
		if var command:MilightDriver.Command = self[[mode : action]]{
            command.argumentTransformer = argumentTransformer
            self[[mode : action]] = command
        }
    }
    
}

extension Dictionary where Key == [MilightDriver.Mode : String] ,  Value == [MilightDriver.Action] {
    
    public mutating func define(mode:MilightDriver.Mode, recipeName:String, actions:[MilightDriver.Action]){
        self[[mode : recipeName]] = actions
    }
    
	public mutating func addArgumentTranformer(mode:MilightDriver.Mode, recipeName:MilightDriver.Action, _ argumentTransformer:@escaping (Any)->[UInt8?]){
//        if var command:Command = self[[mode : action]]{
//            command.argumentTransformer = argumentTransformer
//            self[[mode : action]] = command
//        }
    }
    
}

