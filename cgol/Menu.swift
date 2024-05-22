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
        ZStack {
            Color.clear

            if isVisible {
                VStack {
                    Text("My Game")
                        .font(.largeTitle)
                        .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                .background(Color.white.opacity(0.8))
                .cornerRadius(15) // Add rounded corners
                .shadow(radius: 10) // Optional: add a shadow for better visual separation
                .padding() // Add padding around the VStack

            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        //.background(Color.gray) // Optional: set a background color to see the whole view area
        .edgesIgnoringSafeArea(.all) // Ensures the view covers the entire screen
        .onHover { hovering in
            withAnimation {
                isVisible = hovering
            }
        }
    }
}
