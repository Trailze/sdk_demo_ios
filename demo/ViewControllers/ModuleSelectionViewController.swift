//
//  ModuleSelectionPopup.swift
//  Client
//
//  Created by Yoav Pasovsky on 01.12.21.
//

import UIKit

class ModuleSelectionViewController: UIViewController {
    private lazy var showManeuverToggle: LabeledToggle = {
        let toggle = LabeledToggle.createLabeledSwitch(title: "Show Maneuvers")
        toggle.isOn = true
        return toggle
    }()
    
    private lazy var showInstructionToggle: LabeledToggle = {
        let toggle = LabeledToggle.createLabeledSwitch(title: "Show Instructions")
        toggle.isOn = true
        return toggle
    }()
    
    private lazy var playInstructionAudioToggle: LabeledToggle = {
        let toggle = LabeledToggle.createLabeledSwitch(title: "Play Audio Instructions")
        toggle.isOn = true
        return toggle
    }()
    
    private lazy var showTimeAndDistanceToggle: LabeledToggle = {
        let toggle = LabeledToggle.createLabeledSwitch(title: "Show Time and Distance")
        toggle.isOn = true
        return toggle
    }()
    
    private lazy var darkOverlay: UIView = {
        let v = UIView()
        v.backgroundColor = .init(white: 0, alpha: 0.8)
        let tapGR = UITapGestureRecognizer.init(target: self, action: #selector(tapGRAction))
        v.addGestureRecognizer(tapGR)
        return v
    }()
    
    private lazy var container: UIView = {
        let v = UIView()
        v.backgroundColor = .init(white: 0.9, alpha: 1)
        v.layer.cornerRadius = 20
        return v
    }()
    
    private lazy var continueButton: UIButton = {
        let b = UIButton()
        b.addTarget(self, action: #selector(continueButtonAction), for: .touchUpInside)
        b.backgroundColor = .systemGreen
        b.setTitle("Continue", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.layer.cornerRadius = 8
        return b
    }()
    
    private lazy var cancelButton: UIButton = {
        let b = UIButton()
        b.addTarget(self, action: #selector(cancelButtonAction), for: .touchUpInside)
        b.backgroundColor = .systemRed
        b.setTitle("Cancel", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.layer.cornerRadius = 8
        return b
    }()
    
    let startNavigationCompletion: (UIViewController, ModularNavigationViewControllerOptions) -> Void
    let cancelNavigationCompletion: (UIViewController) -> Void
    
    init(navigationCompletion: @escaping (UIViewController, ModularNavigationViewControllerOptions) -> Void, cancelCompletion: @escaping (UIViewController) -> Void) {
        self.startNavigationCompletion = navigationCompletion
        self.cancelNavigationCompletion = cancelCompletion
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        for v in [darkOverlay, container] {
            view.addSubview(v)
        }
        
        for v in [showManeuverToggle, showInstructionToggle, playInstructionAudioToggle, showTimeAndDistanceToggle, continueButton, cancelButton] {
            container.addSubview(v)
        }
        
        layoutUI()
    }
    
    private func layoutUI() {
        darkOverlay.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        container.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(20)
            make.right.equalToSuperview().inset(20)
        }
        
        showManeuverToggle.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(20)
            make.left.right.equalToSuperview().inset(20)
        }
        
        showInstructionToggle.snp.makeConstraints { make in
            make.top.equalTo(showManeuverToggle.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
        }
        
        playInstructionAudioToggle.snp.makeConstraints { make in
            make.top.equalTo(showInstructionToggle.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
        }
        
        showTimeAndDistanceToggle.snp.makeConstraints { make in
            make.top.equalTo(playInstructionAudioToggle.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
        }
        
        continueButton.snp.makeConstraints { make in
            make.top.equalTo(showTimeAndDistanceToggle.snp.bottom).offset(30)
            make.right.equalToSuperview().inset(30)
            make.bottom.equalToSuperview().inset(20)
            make.height.equalTo(45)
            make.width.equalTo(120)
        }
        
        cancelButton.snp.makeConstraints { make in
            make.centerY.equalTo(continueButton)
            make.left.equalToSuperview().inset(30)
            make.bottom.equalToSuperview().inset(20)
            make.height.equalTo(45)
            make.width.equalTo(120)
        }
    }
    
    @objc private func tapGRAction() {
        cancelNavigationCompletion(self)
    }
    
    @objc private func cancelButtonAction() {
        cancelNavigationCompletion(self)
    }
    
    @objc private func continueButtonAction() {
        let options = ModularNavigationViewControllerOptions.init(showManeuver: showManeuverToggle.isOn,
                                                                  showInstruction: showInstructionToggle.isOn,
                                                                  playInstructionAudio: playInstructionAudioToggle.isOn,
                                                                  showTimeAndDistance: showTimeAndDistanceToggle.isOn)
        startNavigationCompletion(self, options)
    }
}

class LabeledToggle: UIView  {
    internal var toggle: UISwitch!
    internal var label: UILabel!
    
    var isOn: Bool {
        get {
            toggle.isOn
        }
        set {
            toggle.isOn = newValue
        }
    }
    
    static func createLabeledSwitch(title: String) -> LabeledToggle {
        let s = UISwitch()

        let l = UILabel()
        l.text = title
        l.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        l.textColor = .black
        
        let view = LabeledToggle()
        
        for v in [l, s] {
            view.addSubview(v)
        }
        
        view.toggle = s
        view.label = l
        
        l.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10)
            make.left.equalToSuperview().inset(22)
            make.bottom.equalToSuperview().inset(10)
        }
        
        s.snp.makeConstraints { make in
            make.centerY.equalTo(l.snp.centerY)
            make.right.equalToSuperview().inset(22)
        }
        
        return view
    }
}
