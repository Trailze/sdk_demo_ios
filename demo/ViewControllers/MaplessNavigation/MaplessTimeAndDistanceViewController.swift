//
//  MaplessTimeAndDistanceViewController.swift
//  Trailze
//
//  Created by Yoav Pasovsky on 30.11.21.
//

import UIKit
import CoreLocation
import MapboxCoreNavigation
import MapboxDirections
import Trailze

class MaplessTimeAndDistanceViewController: UIViewController {
    
    private lazy var distanceRemainingLabel: UILabel = {
        let l = UILabel()
        l.textColor = .label
        l.font = .systemFont(ofSize: 80, weight: .bold)
        l.textAlignment = .center
        return l
    }()
        
    var progress: Float {
        get {
            return progressBar.progress
        }
        set {
            progressBar.setProgress(newValue, animated: false)
        }
    }
    
    private lazy var progressBar: UIProgressView = {
        let p = UIProgressView()
        p.progressTintColor = .label
        p.layer.cornerRadius = 2
        return p
    }()
    
    let container = UIView()
    let dateFormatter = DateFormatter()
    let dateComponentsFormatter = DateComponentsFormatter()
    let distanceFormatter = DistanceFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.translatesAutoresizingMaskIntoConstraints = false
        dateFormatter.timeStyle = .short
        dateComponentsFormatter.allowedUnits = [.hour, .minute]
        dateComponentsFormatter.unitsStyle = .abbreviated
        
        view.addSubview(container)
        for v in [distanceRemainingLabel, progressBar] {
            container.addSubview(v)
        }
        
        layoutUI()
    }
    
    func layoutUI() {
        container.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        distanceRemainingLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10)
            make.centerX.equalToSuperview()
        }
        
        progressBar.snp.makeConstraints { make in
            make.top.equalTo(distanceRemainingLabel.snp.bottom).offset(50)
            make.left.right.equalToSuperview().inset(10)
            make.height.equalTo(4)
        }
    }
    
    func updateETA(routeProgress: RouteProgress) {
        if routeProgress.durationRemaining < 5 {
            distanceRemainingLabel.text = " "
        } else {
            distanceRemainingLabel.text = distanceFormatter.string(from: routeProgress.currentLegProgress.currentStepProgress.distanceRemaining)
        }
        
        progress = Float(routeProgress.fractionTraveled)
    }
}

extension MaplessTimeAndDistanceViewController: TRLNavigationServiceDelegate {
    func navigationService(didUpdate progress: RouteProgress, with location: CLLocation) {
        updateETA(routeProgress: progress)
    }
    
    func navigationService(didArriveAt waypoint: Waypoint) -> Bool {
        progress = 1.0
        return false
    }
}
