//
//  Menu.swift
//  cgol
//
//  Created by Kane Sweet on 5/21/24.
//
import SwiftUI
import Combine

struct ContentView: View {
    @State private var isVisible: Bool = false


    var body: some View {
        VStack {
            if isVisible {
                VStack {
                    Text("My Game")
                        .font(.largeTitle)
                        .padding()
                }
                .background(Color.white)
                .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            }
            else {
                Color.clear
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onHover { hovering in
            print("hovering2 = " + String(hovering))
            withAnimation {
                isVisible = hovering
            }
        }
    }
}
