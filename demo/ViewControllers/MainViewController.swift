//
//  MainViewController.swift
//  demo
//
//  Created by Yoav Pasovsky on 31.08.21.
//

import UIKit
import Trailze

class MainViewController: UIViewController {
    
    private lazy var titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Which navigation experience would you like to try out?"
        l.textColor = .label
        l.numberOfLines = 0
        l.textAlignment = .center
        l.font = .systemFont(ofSize: 20, weight: .bold)
        return l
    }()
    
    private lazy var batteriesIncludedButton: UIButton = {
        menuButton(title: "Batteries included", action: #selector(batteriesIncludedAction))
    }()
    private lazy var modularMapNavigationButton: UIButton = {
        menuButton(title: "Modular UI (with map)", action: #selector(modularMapNavigationAction))
    }()
    private lazy var modularMaplessNavigationButton: UIButton = {
        menuButton(title: "Modular UI (mapless)", action: #selector(modularMaplessNavigationAction))
    }()
    
    private lazy var container: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.init(white: 0.9, alpha: 1)
        v.layer.cornerRadius = 20
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Step-by-step Navigation Demo"
        view.backgroundColor = UIColor.init(red: 0.1, green: 0.5, blue: 0.8, alpha: 1.0)
        
        view.addSubview(container)
        for v in [titleLabel, batteriesIncludedButton, modularMapNavigationButton, modularMaplessNavigationButton] {
            container.addSubview(v)
        }
    
        container.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.right.equalToSuperview().inset(10)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalToSuperview().inset(25)
        }
        
        batteriesIncludedButton.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(30)
            make.left.right.equalToSuperview().inset(10)
            make.height.equalTo(50)
        }
        
        modularMapNavigationButton.snp.makeConstraints { make in
            make.top.equalTo(batteriesIncludedButton.snp.bottom).offset(25)
            make.left.right.equalToSuperview().inset(10)
            make.height.equalTo(50)
        }
        
        modularMaplessNavigationButton.snp.makeConstraints { make in
            make.top.equalTo(modularMapNavigationButton.snp.bottom).offset(25)
            make.left.right.equalToSuperview().inset(10)
            make.height.equalTo(50)
            make.bottom.equalToSuperview().inset(40)
        }
    }
    
    private func menuButton(title: String, action: Selector) -> UIButton {
        let b = UIButton()
        b.setTitle(title, for: .normal)
        b.setTitleColor(.systemBlue, for: .normal)
        b.setTitleColor(.systemOrange, for: .highlighted)
        b.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
        b.addTarget(self, action: action, for: .touchUpInside)
        return b
    }
    
    @objc private func batteriesIncludedAction() {
        let logo = UIImage(named: "logo")!
        let vc = getTrailzeSearchUI(logo: logo)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func modularMapNavigationAction() {
        let vc = AddressSearchViewController(with: .mapModular)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func modularMaplessNavigationAction() {
        let vc = AddressSearchViewController(with: .maplessModular)
        navigationController?.pushViewController(vc, animated: true)
    }
}
