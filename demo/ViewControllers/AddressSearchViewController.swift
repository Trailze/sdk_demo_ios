//
//  AddressSearchViewController.swift
//  demo
//
//  Created by Yoav Pasovsky on 03.12.21.
//

import UIKit
import Trailze
import MapboxDirections

enum PresentationMode {
    case mapModular, maplessModular
}

class AddressSearchViewController: UIViewController {
    let presentationMode: PresentationMode
    init(with mode: PresentationMode) {
        self.presentationMode = mode
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = presentationMode == .mapModular ? "Modular Map Navigation" : "Modular Mapless Navigation"
        let vc = TRLAddressSearchViewController()
        vc.delegate = self
        addChild(vc)
        view.addSubview(vc.view)
        vc.didMove(toParent: self)
        vc.view.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }
    }
}

extension AddressSearchViewController: TRLAddressSearchViewControllerDelegate {
    func routeSummaryViewControllerDidChooseSteps() {}
    
    func routeSummaryViewControllerDidChooseStart(routes: [Route]?) {
        print("routeSummaryViewControllerDidChooseStart")
        guard let routes = routes else {
            fatalError("No routes exist")
        }
        
        let moduleVC = ModuleSelectionViewController.init { childVC, options in
            let modularVC: ModularNavigationViewController = self.modularViewControllerForMode(self.presentationMode, routes: routes, options: options)
            modularVC.modalPresentationStyle = .fullScreen
            modularVC.delegate = self
            childVC.willMove(toParent: nil)
            childVC.removeFromParent()
            childVC.view.removeFromSuperview()
            self.present(modularVC, animated: true) {
                
            }
        } cancelCompletion: { vc in
            UIView.animate(withDuration: 0.25) {
                vc.view.alpha = 0
            } completion: { finished in
                vc.willMove(toParent: nil)
                vc.removeFromParent()
                vc.view.removeFromSuperview()
            }
        }
        
        moduleVC.willMove(toParent: self)
        addChild(moduleVC)
        moduleVC.view.alpha = 0
        view.addSubview(moduleVC.view)
        moduleVC.didMove(toParent: self)
        UIView.animate(withDuration: 0.25) {
            moduleVC.view.alpha = 1
        }
    }
    
    func modularViewControllerForMode(_ mode: PresentationMode, routes: [Route], options: ModularNavigationViewControllerOptions) -> ModularNavigationViewController
    {
        mode == .mapModular ?
        ModularMapNavigationViewController.init(routes: routes, options: options)
        :
        ModularMaplessNavigationViewController.init(routes: routes, options: options)
    }
}

extension AddressSearchViewController: ModularNavigationViewControllerDelegate {
    func didTapDismiss() {
        dismiss(animated: true, completion: nil)
    }
}
