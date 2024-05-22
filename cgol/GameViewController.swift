//
//  GameViewController.swift
//  cgol
//
//  Created by Kane Sweet on 9/6/23.
//

import UIKit
import MetalKit
import SwiftUI
import Combine

// Our iOS specific view controller
class GameViewController: UIViewController {

    var renderer: Renderer!
    var mtkView: MTKView!
    private var isVisible = CurrentValueSubject<Bool, Never>(false)
    private var subscriptions = Set<AnyCancellable>()
    var menuContainerView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMtkView()
        setupMenuView()

    }

    func setupMtkView() {

        guard let mtkView = view as? MTKView else {
            print("View of Gameview controller is not an MTKView")
            return
        }
        // Select the device to render with.  We choose the default device
        guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
            print("Metal is not supported")
            return
        }

        mtkView.device = defaultDevice
        mtkView.backgroundColor = UIColor.black

        // Add the MTKView to the view hierarchy
        // view.addSubview(mtkView)



        guard let newRenderer = Renderer(metalKitView: mtkView) else {
            print("Renderer cannot be initialized")
            return
        }

        renderer = newRenderer

        renderer.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)

        mtkView.delegate = renderer
    }

    func setupMenuView() {
        // Add the SwiftUI view
        let swiftUIView = ContentView()
        let hostingController = UIHostingController(rootView: swiftUIView)
        addChild(hostingController)
        view.addSubview(hostingController.view)

        // Set up the constraints for the hosting controller's view
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.heightAnchor.constraint(equalToConstant: 200),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        hostingController.view.backgroundColor = .clear

        hostingController.didMove(toParent: self)
    }
}
