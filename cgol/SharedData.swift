//
//  SharedData.swift
//  cgol
//
//  Created by Kane Sweet on 5/22/24.
//

import Foundation

class SharedData: ObservableObject {
    @Published var alpha: Int = 2
    @Published var beta: Int = 3
    @Published var gamma: Int = 3
}
