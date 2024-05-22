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
    @StateObject var sharedData: SharedData

    var body: some View {
        ZStack {
            Color.clear

            if isVisible {
                VStack {
                    HStack {
                        //Text("Alpha")
                        Slider(
                            value: .convert(from: $sharedData.alpha),
                            in: 0...8
                        )
                    }.padding(.horizontal)
                    HStack {
                        //Text("Beta")
                        Slider(
                            value: .convert(from: $sharedData.beta),
                            in: 0...8
                        )
                    }.padding(.horizontal)
                    HStack {
                        //Text("Gamma")
                        Slider(
                            value: .convert(from: $sharedData.gamma),
                            in: 0...8
                        )
                    }.padding(.horizontal)

                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                .background(Color.white.opacity(0.7))
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

public extension Binding {

    static func convert<TInt, TFloat>(from intBinding: Binding<TInt>) -> Binding<TFloat>
    where TInt:   BinaryInteger,
          TFloat: BinaryFloatingPoint{

        Binding<TFloat> (
            get: { TFloat(intBinding.wrappedValue) },
            set: { intBinding.wrappedValue = TInt($0) }
        )
    }

    static func convert<TFloat, TInt>(from floatBinding: Binding<TFloat>) -> Binding<TInt>
    where TFloat: BinaryFloatingPoint,
          TInt:   BinaryInteger {

        Binding<TInt> (
            get: { TInt(floatBinding.wrappedValue) },
            set: { floatBinding.wrappedValue = TFloat($0) }
        )
    }
}
