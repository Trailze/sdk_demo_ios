//
//  CoordinateEntryViewController.swift
//  Client
//
//  Created by Pasovsky Yoav on 16.05.22.
//

import UIKit
import Trailze
import Mapbox
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections

public class CoordinateEntryViewController: UIViewController, MGLMapViewDelegate {
    var origin: CLLocationCoordinate2D?
    var destination: CLLocationCoordinate2D?
    var routes: [Route]?
    
    private lazy var mapVC: TRLSearchMapViewController = {
        let vc = TRLSearchMapViewController()
        vc.delegate = self
        return vc
    }()
    
    private lazy var enterCoordinatesButton: UIButton = {
        let b = UIButton()
        b.addTarget(self, action: #selector(addCoordinates), for: .touchUpInside)
        b.backgroundColor = .systemBlue
        b.setTitle("Enter Coordinates", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 20)
        b.alpha = 1
        return b
    }()
    
    private lazy var startButton: UIButton = {
        let b = UIButton()
        b.addTarget(self, action: #selector(startButtonAction), for: .touchUpInside)
        b.backgroundColor = .systemGreen
        b.setTitle("Start", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 20)
        b.alpha = 0
        return b
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barStyle = .default
        self.navigationController?.navigationBar.tintColor = .black
        
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
        
        view.backgroundColor = .systemBackground
        addChild(mapVC)
        
        for v: UIView in [mapVC.view, enterCoordinatesButton, startButton] {
            view.addSubview(v)
        }
        
        mapVC.didMove(toParent: self)
        layoutUI()
    }
    
    private func layoutUI() {
        mapVC.view.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().inset(100)
        }
        
        enterCoordinatesButton.snp.makeConstraints { make in
            make.height.equalTo(100)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        startButton.snp.makeConstraints { make in
            make.height.equalTo(100)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    func updateMap() {
        let routingRequestCompletion: (Result<([Waypoint]?, [Route]?, [TRLRoute]?), Error>) -> Void = { result in
            switch result {
            case .success(let (_, routes, trRoutes)):
                self.mapVC.updateRoutes(routes: routes, trailzeRoutes: trRoutes)
                self.routes = routes
                if let trRoute = trRoutes?.first {
                    UIView.animate(withDuration: 0.5) {
                        self.enterCoordinatesButton.alpha = 0
                        self.startButton.alpha = 1
                    } completion: { _ in }
                    // display metadata about route
                }
                return
            case .failure(let error):
                self.mapVC.updateRoutes(routes: nil, trailzeRoutes: nil)
                self.presentAlert(title: "Error", message: error.localizedDescription)
            }
        }
        
        guard origin != nil, destination != nil else { return }
        TrailzeApp.getRoute(origin: origin!, destination: destination!, language: .fr, travelMode: nil, completion: routingRequestCompletion)
    }
    
    func presentAlert(title: String, message: String) {
        let actionSheet = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "OK", style: .default, handler: nil)
        actionSheet.addAction(dismiss)
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @objc private func addCoordinates() {
        let ac = UIAlertController(title: "Enter coordinates", message: nil, preferredStyle: .alert)
        ["Origin Lat", "Origin Lon", "Destination Lat", "Destination Lon"].forEach { (placeholder) in
            ac.addTextField {
                $0.placeholder = placeholder
                $0.keyboardType = .numbersAndPunctuation
            }
        }
        
        let submitAction = UIAlertAction(title: "Add", style: .default) { [unowned ac] _ in
            let originLatTF = ac.textFields![0]
            let originLonTF = ac.textFields![1]
            let destinationLatTF = ac.textFields![2]
            let destinationLonTF = ac.textFields![3]
            
            guard originLatTF.text?.count ?? 0 > 0 &&
                  originLonTF.text?.count ?? 0 > 0 &&
                  destinationLatTF.text?.count ?? 0 > 0 &&
                  destinationLonTF.text?.count ?? 0 > 0 else {
                return
            }
            
            let origin = CLLocationCoordinate2D(latitude: (originLatTF.text! as NSString).doubleValue, longitude: (originLonTF.text! as NSString).doubleValue)
            let destination = CLLocationCoordinate2D(latitude: (destinationLatTF.text! as NSString).doubleValue, longitude: (destinationLonTF.text! as NSString).doubleValue)
            
            self.origin = origin
            self.destination = destination
            
            self.updateMap()
            
            self.view.setNeedsLayout()
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    @objc private func startButtonAction() {
        guard let routes = routes else {
            fatalError("No routes exist")
        }
        
        let moduleVC = ModuleSelectionViewController.init { childVC, options in
            let modularVC: ModularNavigationViewController = ModularMapNavigationViewController.init(routes: routes, options: options)
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
}

extension CoordinateEntryViewController: TRLSearchMapViewControllerDelegate {
    public func searchMapViewControllerDidSelectRoute(route: TRLRoute) {
        print("Did select route")
        // display metadata about selected route
    }
}

extension CoordinateEntryViewController: ModularNavigationViewControllerDelegate {
    public func didTapDismiss() {
        dismiss(animated: true, completion: nil)
    }
}
