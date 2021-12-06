//
//  ManeuverAndDistanceViewController.swift
//  demo
//
//  Created by Yoav Pasovsky on 06.12.21.
//

import UIKit
import CoreLocation
import MapboxDirections
import MapboxCoreNavigation
import MapboxNavigation
import Trailze

class ManeuverAndDistanceViewController: UIViewController {
    private lazy var distanceRemainingLabel: UILabel = {
        let l = UILabel()
        l.textColor = .white
        l.font = .systemFont(ofSize: 16, weight: .regular)
        l.textAlignment = .left
        return l
    }()
    
    private lazy var maneuverVC: ManeuverViewController = {
        let vc = ManeuverViewController(with: CGSize(size: 42))
        vc.maneuverView.primaryColor = .white
        return vc
    }()
    
    let distanceFormatter = DistanceFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.translatesAutoresizingMaskIntoConstraints = false
        maneuverVC.willMove(toParent: self)
        addChild(maneuverVC)
        view.addSubview(maneuverVC.view)
        maneuverVC.didMove(toParent: self)
        view.addSubview(distanceRemainingLabel)
        layoutUI()
    }
    
    func layoutUI() {
        maneuverVC.view.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().offset(-10)
            make.left.equalToSuperview().inset(10)
            make.height.equalTo(50)
            make.width.equalTo(50)
        }
        
        distanceRemainingLabel.snp.makeConstraints { make in
            make.top.equalTo(maneuverVC.view.snp.bottom)
            make.left.equalTo(maneuverVC.view.snp.left)
        }
    }
    
    func updateETA(routeProgress: RouteProgress) {
        if routeProgress.durationRemaining < 5 {
            distanceRemainingLabel.text = nil
        } else {
            distanceRemainingLabel.text = distanceFormatter.string(from: routeProgress.currentLegProgress.currentStepProgress.distanceRemaining)
        }
    }
}

extension ManeuverAndDistanceViewController: TRLNavigationServiceDelegate {
    func navigationService(didUpdate progress: RouteProgress, with location: CLLocation) {
        updateETA(routeProgress: progress)
    }
    
    func navigationService(didPassVisualInstructionPoint instruction: VisualInstructionBanner, routeProgress: RouteProgress) {
        maneuverVC.navigationService(didPassVisualInstructionPoint: instruction, routeProgress: routeProgress)
    }
}
