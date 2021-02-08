// Special thanks to Derik Ramirez (https://rderik.com)
// for his great article on writing a (native) Swift UDP-client

import Foundation
import Network

class UDPClient {
    
    let maxUDPPackageSize = 65535 //The UDP maximum package size is 64K
    let name: String
    let host: NWEndpoint.Host
    let port: NWEndpoint.Port
    let udpConnection: NWConnection
    var dataReceiver:((Data?, NWConnection.ContentContext?, Bool, NWError?) -> Void)! = nil
    
    let queue = DispatchQueue(label: "UDP-client connection events Q")
    
    init(name: String, host: String, port: UInt16){
        self.name = name
        self.host = NWEndpoint.Host(host)
        self.port = NWEndpoint.Port(rawValue: port)!
        self.udpConnection = NWConnection(host: self.host, port: self.port, using: .udp)
        self.udpConnection.stateUpdateHandler = self.connectionStateChanged(to:)
    }
    
    func connect() {
        udpConnection.start(queue: queue)
        print("ℹ️\tUDP-connection made with @IP \(host): \(port)")
    }
    
    func disconnect() {
        stop(error: nil)
        print("ℹ️\tUDP-connection closed with @IP \(host): \(port)")
    }
    
    func reconnect() {
        disconnect()
        connect()
        
    }
    
    func send(data: Data) {
        self.udpConnection.receive(minimumIncompleteLength: 1, maximumLength: maxUDPPackageSize, completion: self.dataReceiver)
        udpConnection.send(content: data, completion: .contentProcessed( { error in
            if let error = error {
                self.connectionDidFail(error: error)
                return
            }
        }))
        print("ℹ️\tData sent to UDP-connection @IP \(host): \(port): \(data as NSData)")
    }
    
    
    // MARK: - Connection event handlers
    
    private func connectionStateChanged(to state: NWConnection.State) {
        switch state {
        case .waiting(let error):
            connectionDidFail(error: error)
        case .ready:
            print("ℹ️\tUDP-connection @IP \(host): \(port) ready")
        case .failed(let error):
            connectionDidFail(error: error)
        default:
            break
        }
    }
    
    private func connectionDidFail(error: Error) {
        print("ℹ️\tUDP-connection @IP \(host): \(port) did fail, error: \(error)")
        self.stop(error: error)
    }
    
    private func connectionDidEnd() {
        print("ℹ️\tUDP-connection @IP \(host): \(port) did end")
        self.stop(error: nil)
    }
    
    // MARK: - Subroutines
    
    private func stop(error: Error?) {
        udpConnection.stateUpdateHandler = nil
        udpConnection.cancel()
    }
    
    
}
