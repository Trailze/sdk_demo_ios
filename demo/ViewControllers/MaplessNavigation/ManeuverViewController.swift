//
//  ManeuverViewController.swift
//  Trailze
//
//  Created by Yoav Pasovsky on 21.11.21.
//

import UIKit
import MapboxDirections
import MapboxCoreNavigation
import MapboxNavigation
import Trailze

class ManeuverViewController: UIViewController {
    var maneuverView: ManeuverView!
    let size: CGSize
    
    init(with size: CGSize) {
        self.size = size
        maneuverView = ManeuverView()
        maneuverView.primaryColor = .label
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(maneuverView)
        layoutUI()
    }
    
    func layoutUI() {
        maneuverView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.size.equalTo(size)
        }
    }
}

extension ManeuverViewController: TRLNavigationServiceDelegate {
    func navigationService(didPassVisualInstructionPoint instruction: VisualInstructionBanner, routeProgress: RouteProgress) {
        maneuverView.visualInstruction = instruction.primaryInstruction
    }
}
