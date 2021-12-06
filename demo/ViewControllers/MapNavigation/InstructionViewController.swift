//
//  InstructionViewController.swift
//  Trailze
//
//  Created by Yoav Pasovsky on 21.11.21.
//

import UIKit
import MapboxDirections
import MapboxCoreNavigation
import MapboxNavigation
import Trailze

class InstructionViewController: UIViewController {
    lazy var instructionLabel: UILabel = {
        let l = UILabel()
        l.textColor = .label
        l.text = ""
        l.font = .systemFont(ofSize: 30, weight: .bold)
        l.lineBreakMode = .byWordWrapping
        l.numberOfLines = 0
        l.textAlignment = .left
        
        return l
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(instructionLabel)
        instructionLabel.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview().inset(5)
            make.left.right.equalToSuperview().inset(5)
        }
    }
}

extension InstructionViewController: TRLNavigationServiceDelegate {    
    func navigationService(didPassVisualInstructionPoint instruction: VisualInstructionBanner, routeProgress: RouteProgress) {
        instructionLabel.text = instruction.primaryInstruction.text
    }
}
