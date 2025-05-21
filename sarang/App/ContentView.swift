//
//  ContentView.swift
//  sarang
//
//  Created by Samuel Lee on 5/14/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    @Environment(\.modelContext) private var context
    
    @Query private var items: [DataItem]
    
    var body: some View {
        VStack {
            Text("Tap on this button to add data")
            HStack {
                Button("Add an item"){
                    addItem()
                }
                Button("Delete all"){
                    deleteItems()
                }
                
            }
            
            List {
                ForEach(items) { item in
                
                    HStack {
                        Text(item.name)
                        Spacer()
                        Button {
                            updateItem(item)
                        } label: {
                            Image(systemName: "pencil")
                        }
                    }
                
                }
                .onDelete { indexes in
                    for index in indexes {
                        deleteItem(items[index])
                    }
                }
            }
        }
        .padding()
    }
    
    func addItem() {
        // Create the item
        let item = DataItem(name: "Test Item")
        context.insert(item)
    }
    
    func deleteItem(_ item: DataItem) {
        context.delete(item)
    }
    
    func updateItem(_ item: DataItem) {
        item.name = "Updated Item"
        try? context.save()
    }
    
    func deleteItems() {
        for item in items {
            deleteItem(item)
        }
    }
}

#Preview {
    ContentView()
}
