//
//  TRLMapNavigationContainerVC.swift
//  Trailze
//
//  Created by Yoav Pasovsky on 19.11.21.
//

import UIKit
import AVKit
import MapboxDirections
import MapboxCoreNavigation
import MapboxNavigation
import CoreLocation
import Trailze

public struct ModularNavigationViewControllerOptions {
    let showManeuver: Bool
    let showInstruction: Bool
    let playInstructionAudio: Bool
    let showTimeAndDistance: Bool
    let simulateNavigation: Bool
    
    public init(showManeuver: Bool = false,
         showInstruction: Bool = false,
         playInstructionAudio: Bool = false,
         showTimeAndDistance: Bool = false,
         simulateNavigation: Bool = false
         ) {
        self.showManeuver = showManeuver
        self.showInstruction = showInstruction
        self.playInstructionAudio = playInstructionAudio
        self.showTimeAndDistance = showTimeAndDistance
        self.simulateNavigation = simulateNavigation
    }
}

protocol ModularNavigationViewController: UIViewController {
    var delegate: ModularNavigationViewControllerDelegate? { get set }
}

public class ModularMapNavigationViewController: UIViewController, ModularNavigationViewController {
    internal var mapViewController: TRLMapNavigationViewController!
    let options: ModularNavigationViewControllerOptions
    var navService: TRLNavigationService!
    let routes: [Route]
    public var delegate: ModularNavigationViewControllerDelegate?
    let topContainerView = UIView()
    let bottomContainerView = UIView()
    
    private lazy var exitButton: UIButton = {
        let b = UIButton()
        b.setTitle("Exit", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
        b.tintColor = .white
        b.backgroundColor = .systemRed
        b.layer.cornerRadius = 30
        b.addTarget(self, action: #selector(exitAction), for: .touchUpInside)
        return b
    }()
    
    private lazy var recenterButton: UIButton = {
        let b = UIButton()
        b.setTitle("Recenter", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
        b.tintColor = .white
        b.backgroundColor = .systemGreen
        b.layer.cornerRadius = 30
        b.addTarget(self, action: #selector(recenterAction), for: .touchUpInside)
        b.isHidden = true
        return b
    }()

    var navigationComponents: [UIViewController & TRLNavigationServiceDelegate] = []
    
    public init(routes: [Route], options: ModularNavigationViewControllerOptions?) {
        self.routes = routes
        self.options = options ?? ModularNavigationViewControllerOptions()
        guard let firstRoute = self.routes.first else {
            fatalError("Routes can't be empty")
        }
        self.navService = TRLNavigationService.init(route: firstRoute, simulating: self.options.simulateNavigation)
        if (!self.options.playInstructionAudio) {
            navService.voiceController = nil
        }
        self.mapViewController = TRLMapNavigationViewController.init(route: firstRoute, navigationService: navService.navigationService)    
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.mapViewController.delegate = self
        navService.trailzeNavigationServiceDelegate = self
        embed(mapViewController, parentView: view)
        navigationComponents.append(mapViewController)
        for v in [topContainerView, bottomContainerView] {
            view.addSubview(v)
        }
        
        if (options.showManeuver || options.showInstruction) {
            setupTopContainer()
        }
        
        if (options.showTimeAndDistance) {
            setupBottomContainer()
        } else {
            for v in [exitButton, recenterButton] {
                view.addSubview(v)
            }
            
            exitButton.snp.makeConstraints { (make) in
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(50)
                make.right.equalToSuperview().inset(16)
                make.height.equalTo(60)
                make.width.equalTo(70)
            }
            
            recenterButton.snp.makeConstraints { (make) in
                make.centerY.equalTo(exitButton)
                make.right.equalTo(exitButton.snp.left).inset(-20)
                make.height.equalTo(60)
                make.width.equalTo(110)
            }
        }
    }
    
    private func setupTopContainer() {
        topContainerView.backgroundColor = UIColor.init(red: 0, green: 0.62, blue: 0.93, alpha: 1)
        topContainerView.layer.cornerRadius = 10
        
        topContainerView.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(20)
            make.left.right.equalToSuperview().inset(8)
            make.height.equalTo(87)
        }
        
        if (options.showManeuver) {
            let vc = ManeuverAndDistanceViewController()
            embed(vc, parentView: topContainerView)
            navigationComponents.append(vc)
            vc.view.snp.makeConstraints { (make) in
                    make.centerY.equalToSuperview()
                    make.left.equalToSuperview().inset(10)
                    make.height.equalTo(100)
                    make.width.equalTo(50)
            }
        }
        
        if (options.showInstruction) {
            let vc = InstructionViewController()
            vc.instructionLabel.textColor = .white
            embed(vc, parentView: topContainerView)
            navigationComponents.append(vc)
            vc.view.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.left.equalToSuperview().inset(80) // left padding + maneuver (maybe) + 20 pts padding
                make.height.equalTo(100)
                make.width.equalTo(240)
            }
        }
    }
    
    private func setupBottomContainer() {
        bottomContainerView.backgroundColor = .white
        bottomContainerView.layer.cornerRadius = 10
        
        bottomContainerView.snp.makeConstraints { (make) in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(7)
            make.left.right.equalToSuperview().inset(8)
            make.height.equalTo(87)
        }
        
        if (options.showTimeAndDistance) {
            let vc = TimeAndDistanceViewController()
            embed(vc, parentView: bottomContainerView)
            navigationComponents.append(vc)
            vc.view.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.left.equalToSuperview().inset(10)
                make.height.equalTo(70)
                make.width.equalTo(200)
            }
        }
        
        bottomContainerView.addSubview(exitButton)
        exitButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(16)
            make.height.equalTo(60)
            make.width.equalTo(70)
        }

        bottomContainerView.addSubview(recenterButton)
        recenterButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(exitButton)
            make.right.equalTo(exitButton.snp.left).inset(-20)
            make.height.equalTo(60)
            make.width.equalTo(110)
        }
    }
    
    private func embed(_ vc: UIViewController, parentView: UIView) {
        vc.willMove(toParent: self)
        addChild(vc)
        parentView.addSubview(vc.view)
        vc.didMove(toParent: self)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navService.start()
    }
    
    @objc func exitAction() {
        navService.stop()
        delegate?.didTapDismiss()
    }
    
    @objc private func recenterAction() {
        mapViewController.tracksUserCourse = true
    }
}

extension ModularMapNavigationViewController: TRLNavigationServiceDelegate {
    public func navigationService(didArriveAt waypoint: Waypoint) -> Bool {
        if navService.isFinalLeg {
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                self.delegate?.didTapDismiss()
            }
            return true
        }
        return false
    }
    
    public func navigationService(didRerouteAlong route: Route, at location: CLLocation?) {
    }
    
    public func navigationService(didPassVisualInstructionPoint instruction: VisualInstructionBanner, routeProgress: RouteProgress) {
        for component in navigationComponents {
            component.navigationService(didPassVisualInstructionPoint: instruction, routeProgress: routeProgress)
        }
    }
    
    public func navigationService(didUpdate progress: RouteProgress, with location: CLLocation) {
        for component in navigationComponents {
            component.navigationService(didUpdate: progress, with: location)
        }
    }
}

extension ModularMapNavigationViewController: VoiceControllerDelegate {
    public func voiceController(_ voiceController: RouteVoiceController, spokenInstructionsDidFailWith error: SpeechError) {
        print(error)
    }

    public func voiceController(_ voiceController: RouteVoiceController, didFallBackTo synthesizer: AVSpeechSynthesizer, error: SpeechError) {
        print(error)
    }

    public func voiceController(_ voiceController: RouteVoiceController, didInterrupt interruptedInstruction: SpokenInstruction, with interruptingInstruction: SpokenInstruction) {
    }

    public func voiceController(_ voiceController: RouteVoiceController, willSpeak instruction: SpokenInstruction, routeProgress: RouteProgress) -> SpokenInstruction? {
        return instruction
    }
}

extension ModularMapNavigationViewController: TRLMapNavigationViewControllerDelegate {
    public func navigationMapViewDidStartTrackingCourse(_ mapView: NavigationMapView) {
        recenterButton.isHidden = true
    }
    
    public func navigationMapViewDidStopTrackingCourse(_ mapView: NavigationMapView) {
        recenterButton.isHidden = false
    }
}
