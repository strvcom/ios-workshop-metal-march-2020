//
//  ViewController.swift
//  MetalWorkshop
//
//  Created by Premysl Vlcek on 03/03/2020.
//  Copyright © 2020 STRV. All rights reserved.
//

import UIKit
import MetalKit

final class ViewController: UIViewController {
    
    private let device = MTLCreateSystemDefaultDevice()
    private var renderer: Renderer?

    @IBOutlet private weak var mtkView: MTKView!

    override func viewDidLoad() {
        super.viewDidLoad()

        if let device = device {
            renderer = Renderer(view: mtkView, device: device)
        }
    }
}
