//
//  baseViewModel.swift
//  nostrlight
//
//  Created by Eswar Saladi on 4/4/23.
//

import Foundation
import MnemonicSwift
import breez_sdkFFI

class SDKListener: EventListener {
    func onEvent(e: BreezEvent) {
        print("received event ", e);
    }
}

class BaseViewModel : ObservableObject {
    @Published public var nodeId : String = ""
    @Published public var mnemonicPhrase: String = ""
    @Published public var invoice: String = ""
    @Published public var lspKey: [UInt8] = []
    @Published public var peers: [String] = []
    @Published public var recievedPayments: [Payment] = []
    @Published public var balance: UInt64 = 0
    @Published public var lspPubKey: String = ""
    
    private var client: BlockingBreezServices?
    private var config: Config = Config(breezserver: "https://bs1.breez.technology:443", mempoolspaceUrl: "https://mempool.space", workingDir: FileManager
        .default
        .urls(for: .documentDirectory, in: .userDomainMask)[0].absoluteString, network: .bitcoin, paymentTimeoutSec: 60, defaultLspId: "03cea51f-b654-4fb0-8e82-eca137f236a0", apiKey: "API_KEY_HERE", maxfeeSat: 1000, maxfeepercent: 0.5)
    
    public func createNode(){
        do{
            mnemonicPhrase = try Mnemonic.generateMnemonic(strength: 128, language: .english)
            let seed = try mnemonicToSeed(phrase: mnemonicPhrase)
            let credentials = try registerNode(network: Network.bitcoin, seed: seed)
            client = try initServices(config: config, seed: seed, creds: credentials, listener: SDKListener());
            
            try client!.start()
//            try client?.connectLsp(lspId: "03cea51f-b654-4fb0-8e82-eca137f236a0")
            
            nodeId = try client!.nodeInfo()!.id;
        } catch {
            print(error)
        }
    }
    
    public func reloadNode() {
        do{
            
            let seed = try mnemonicToSeed(phrase: mnemonicPhrase)
            let credentials = try recoverNode(network: Network.bitcoin, seed: seed)
            client = try initServices(config: config, seed: seed, creds: credentials, listener: SDKListener());
            try client!.start()
//            try client?.connectLsp(lspId: "03cea51f-b654-4fb0-8e82-eca137f236a0")
            lspKey = try client!.fetchLspInfo(lspId: "03cea51f-b654-4fb0-8e82-eca137f236a0")?.lspPubkey ?? []
            nodeId = try client!.nodeInfo()!.id;
            balance = try client!.nodeInfo()?.channelsBalanceMsat ?? 0;
            getPayments()
            getLSPPubKey()
            
        } catch {
            print(error)
        }
    }
    
    public func createInvoice(sats: UInt64, description: String){
        do{
            invoice = try client!.receivePayment(amountSats: sats, description: description).bolt11
        } catch {
            print(error)
        }
    }
    
    public func payInvoice(bolt11: String){
        do{
            
//            try client!.sendPayment(bolt11: bolt11, amountSats: .none)
            print(try client!.executeDevCommand(command: "listpeers"))
        } catch {
            print(error)
        }
    }
    
    public func getPayments(){
        do{
            recievedPayments = try client!.listPayments(filter: .all, fromTimestamp: .none, toTimestamp: .none)
        } catch {
            print(error)
        }
    }
    
    public func getLSPPubKey(){
        do{
            let id = try client!.lspId() ?? ""
            lspPubKey = try client!.fetchLspInfo(lspId: id)?.pubkey ?? "Not found"
        }catch {
            print(error)
        }
    }
    
}
