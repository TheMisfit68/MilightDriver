//
//  UDPclient.swift
//  
//
//  Created by Jan Verrept on 16/10/2019.
//

import Foundation
import SystemConfiguration

public class UDPclient{
    
    // MARK: - Setup
    
    let ipAddress:String
    let portNumber:UInt16
    
    var socketAddress:sockaddr_in
    
    init(ipAddress:String?, portNumber:UInt16){
        
        self.ipAddress = ipAddress ?? "127.0.0.1"
        self.portNumber = portNumber
        
        self.socketAddress = sockaddr_in()
        self.socketAddress.sin_len = UInt8(MemoryLayout.size(ofValue: socketAddress))
        self.socketAddress.sin_family = sa_family_t(AF_INET)
        self.socketAddress.sin_addr.s_addr = inet_addr(ipAddress)
        self.socketAddress.sin_port = portNumber.bigEndian //Equivalent to 'byteSwapped'
        
    }
    
    // MARK: - Send
    
    public func send(string: String){
        
        _ = destinationIsOnline
        
        let fd = socket(AF_INET, SOCK_DGRAM, 0) // DGRAM makes it UDP
        
        var localAddressCopy = socketAddress
        
        _ = withUnsafePointer(to: &localAddressCopy) { unsafePtr -> Int in
            // Cast/Rebind the unsafe pointer to sockAddress-pointer in a Swift compatible and safe manner
            let socketAddressPtr = UnsafeRawPointer(unsafePtr).bindMemory(to: sockaddr.self, capacity: 1)
            
            // Send the actual message
            return sendto(fd, string, string.count, 0, socketAddressPtr, socklen_t(socketAddress.sin_len))
        }
        
        close(fd)
        
    }
    
    public func send(data: [UInt8]) {
        
        _ = destinationIsOnline
        
        let fd = socket(AF_INET, SOCK_DGRAM, 0) // DGRAM makes it UDP
        
        var localAddressCopy = socketAddress
        
        _ = withUnsafePointer(to: &localAddressCopy) { unsafePtr -> Int in
            // Cast/Rebind the unsafe pointer to sockAddress-pointer in a Swift compatible and safe manner
            let socketAddressPtr = UnsafeRawPointer(unsafePtr).bindMemory(to: sockaddr.self, capacity: 1)
            
            // Send the actual message
            return sendto(fd, data, data.count, 0, socketAddressPtr, socklen_t(socketAddress.sin_len))
            
        }
        
        close(fd)
    }
    
    
    // MARK: - Receive
    
    public func listen()->String{
        
        return ""
        
    }
    
    public func listen()->[UInt8]{
        
        return [0]
        
    }
    
    // MARK: - Extra's
    
    private var destinationIsOnline:Bool {
        
        var localCopy = socketAddress
        let isOnline = withUnsafePointer(to: &localCopy) { unsafePtr -> Bool in
            // Cast/Rebind the unsafe pointer to sockAddress-pointer in a Swift compatible and safe manner
            let socketAddressPtr = UnsafeRawPointer(unsafePtr).bindMemory(to: sockaddr.self, capacity: 1)
            
            // Check the reachability
            guard let reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault , socketAddressPtr) else{return false}
            var flags: SCNetworkReachabilityFlags = []
            return SCNetworkReachabilityGetFlags(reachability, &flags) && flags.contains(.reachable) && !flags.contains(.connectionRequired)
        }
        
        isOnline ? print("Destination \(ipAddress) is online") : print("Destination \(ipAddress) seems offline")
        return isOnline
        
    }
    
    
}

