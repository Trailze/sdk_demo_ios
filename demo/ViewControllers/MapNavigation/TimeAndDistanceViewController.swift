//
//  TimeAndDistanceViewController.swift
//  Trailze
//
//  Created by Yoav Pasovsky on 23.11.21.
//

import UIKit
import CoreLocation
import MapboxCoreNavigation
import Trailze

class TimeAndDistanceViewController: UIViewController {
    private lazy var timeRemainingLabel: UILabel = {
        let l = UILabel()
        l.textColor = .darkGray
        l.font = .systemFont(ofSize: 24, weight: .bold)
        l.textAlignment = .left
        return l
    }()
    
    private lazy var distanceRemainingLabel: UILabel = {
        let l = UILabel()
        l.textColor = .lightGray
        l.font = .systemFont(ofSize: 16, weight: .regular)
        l.textAlignment = .left
        return l
    }()
    
    private lazy var arrivalTimeLabel: UILabel = {
        let l = UILabel()
        l.textColor = .lightGray
        l.font = .systemFont(ofSize: 16, weight: .regular)
        l.textAlignment = .left
        return l
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
        for v in [timeRemainingLabel, distanceRemainingLabel, arrivalTimeLabel] {
            container.addSubview(v)
        }
        
        layoutUI()
    }
    
    func layoutUI() {
        container.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview()
        }
        
        timeRemainingLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
        }
        
        distanceRemainingLabel.snp.makeConstraints { make in
            make.top.equalTo(timeRemainingLabel.snp.bottom)
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
        }
        
        arrivalTimeLabel.snp.makeConstraints { make in
            make.top.equalTo(timeRemainingLabel.snp.bottom)
            make.left.equalTo(distanceRemainingLabel.snp.right)
            make.right.equalToSuperview()
        }
    }

    func updateETA(routeProgress: RouteProgress) {
        guard let arrivalDate = NSCalendar.current.date(byAdding: .second, value: Int(routeProgress.durationRemaining), to: Date()) else { return }
        arrivalTimeLabel.text = " · " + dateFormatter.string(from: arrivalDate)

        if routeProgress.durationRemaining < 5 {
            distanceRemainingLabel.text = nil
        } else {
            distanceRemainingLabel.text = distanceFormatter.string(from: routeProgress.distanceRemaining)
        }

        dateComponentsFormatter.unitsStyle = routeProgress.durationRemaining < 3600 ? .short : .abbreviated

        if (dateComponentsFormatter.string(from: 61) != nil), routeProgress.durationRemaining < 60 {
            timeRemainingLabel.text = "<1 min"
        } else {
            timeRemainingLabel.text = dateComponentsFormatter.string(from: routeProgress.durationRemaining)
        }
    }
}

extension TimeAndDistanceViewController: TRLNavigationServiceDelegate {
    func navigationService(didUpdate progress: RouteProgress, with location: CLLocation) {
        updateETA(routeProgress: progress)
    }
}
