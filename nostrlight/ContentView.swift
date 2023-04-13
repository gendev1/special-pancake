//
//  ContentView.swift
//  nostrlight
//
//  Created by Eswar Saladi on 4/4/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var vm : BaseViewModel = BaseViewModel()
    
    @State private var sats: String = ""
    @State private var description: String = ""
    
    @State private var payInvoice: String = ""
    
    var body: some View {
        VStack {
            
            Group{
                Text("Breez SDK Test")
                Text(vm.nodeId)
                TextField("Mnemonic", text: $vm.mnemonicPhrase)
                Text("\(vm.balance)")
                HStack{
                    Button("Register Node"){
                        vm.createNode()
                    }
                    Spacer()
                    Button("Recover Node"){
                        vm.reloadNode()
                    }
                }
                Spacer()
                Text(String(bytes: vm.lspKey , encoding: .utf8) ?? "")
                Divider()
                Spacer()
            }
            
            
            
            Group{
                Text("\(vm.lspPubKey)")
                TextField("sats", text: $sats)
                TextField("description", text: $description)
                Button("Create Invoice"){
                    vm.createInvoice(sats: UInt64(sats) ?? 0, description: description)
                }
                TextField("invoice", text: $vm.invoice)
                Spacer()
                Divider()
                Spacer()
            }
            
            
            Group{
                TextField("bolt11 invoice", text: $payInvoice)
                Button("Pay Invoice"){
                    vm.payInvoice(bolt11: payInvoice)
                }
                Spacer()
            }
           
            
            Group{
                List{
                    ForEach(vm.recievedPayments, id: \.self){peer in
                        if(!peer.pending){
                            Text("\(peer.amountMsat / 1000)")
                        }
                    }
                }
            }
            
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
