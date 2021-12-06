//
//  TRLNavigationViewController.swift
//  Trailze
//
//  Created by Yoav Pasovsky on 13.10.21.
//

import UIKit
import AVKit
import MapboxDirections
import MapboxCoreNavigation
import MapboxNavigation
import CoreLocation
import Trailze

public protocol ModularNavigationViewControllerDelegate {
    func didTapDismiss()
}

public class ModularMaplessNavigationViewController: UIViewController, ModularNavigationViewController {
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
        b.addTarget(self, action: #selector(exitButtonAction), for: .touchUpInside)
        return b
    }()
    
    var navigationComponents: [UIViewController & TRLNavigationServiceDelegate] = []
    
    public init(routes: [Route], options: ModularNavigationViewControllerOptions?) {
        self.routes = routes
        self.options = options ?? ModularNavigationViewControllerOptions()
        guard let firstRoute = self.routes.first else {
            fatalError("Routes can't be empty")
        }
        self.navService = TRLNavigationService.init(route: firstRoute)
        if (!self.options.playInstructionAudio) {
            navService.voiceController = nil
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        navService.trailzeNavigationServiceDelegate = self
        view.backgroundColor = .systemBackground
        
        if (options.showManeuver) {
            let size: Double = Double(view.frame.width) * 0.75
            let vc = ManeuverViewController(with: CGSize(size: size))
            embed(vc, parentView: view)
            navigationComponents.append(vc)
            vc.view.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview().multipliedBy(0.75)
                make.height.width.equalTo(size)
            }
        }
        
        if (options.showInstruction) {
            let vc = InstructionViewController()
            vc.instructionLabel.font = .systemFont(ofSize: 42, weight: .bold)
            vc.instructionLabel.textAlignment = .center
            embed(vc, parentView: view)
            navigationComponents.append(vc)
            vc.view.snp.makeConstraints { (make) in
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(25)
                make.left.right.equalToSuperview().inset(10)
                make.height.equalTo(100)
            }
        }
        
        if (options.showTimeAndDistance) {
            let vc = MaplessTimeAndDistanceViewController()
            embed(vc, parentView: view)
            navigationComponents.append(vc)
            vc.view.snp.makeConstraints { (make) in
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
                make.left.right.equalToSuperview()
                make.height.equalTo(300)
            }
        }
        
        view.addSubview(exitButton)
        exitButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(30)
            make.right.equalToSuperview().inset(30)
            make.height.equalTo(60)
            make.width.equalTo(70)
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
    
    @objc func exitButtonAction() {
        navService.stop()
        delegate?.didTapDismiss()
    }
}

extension ModularMaplessNavigationViewController: TRLNavigationServiceDelegate {
    public func navigationService(didArriveAt waypoint: Waypoint) -> Bool {
        if navService.isFinalLeg {
            delegate?.didTapDismiss()
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

extension ModularMaplessNavigationViewController: VoiceControllerDelegate {
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

