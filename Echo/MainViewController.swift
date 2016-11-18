//
//  MainViewController.swift
//  Echo
//
//  Created by Luis Mariano Arobes on 10/10/16.
//  Copyright © 2016 Luis Mariano Arobes. All rights reserved.
//

import UIKit
import MapKit
import Alamofire
import SwiftyJSON
import CoreLocation

class MainViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.delegate = self
        }
    }
    
    @IBOutlet weak var containerPanelView: UIView! {
        didSet {        
            containerPanelView.round()
        }
    }
    
    @IBOutlet weak var panelViewTopConstraint: NSLayoutConstraint!
    
    //MARK: - Variables
    var areas: [Area]!
    
    //Panel variables
    weak var panelViewController: PanelViewController?
    var originalPanelPosition: CGFloat = 0
    var lastPoint: CGPoint = CGPoint.zero
    var panelViewGoingUp = false    
    
    lazy var belugaOverlayView: EchoOverlayView = {
        let belugaOverlayView = EchoOverlayView()
        return belugaOverlayView
    }()
    
    var didZoomToUserLocation = false
    
    //MARK: - Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
        getMyAreas()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Setup
    func setupViews() {
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGesture(gestureRecognizer:)))
        containerPanelView.addGestureRecognizer(gestureRecognizer)
        
        originalPanelPosition = panelViewTopConstraint.constant                
        
        setupBlurredBackgroundToPanelView()
        
        let profileButton = UIBarButtonItem(image: #imageLiteral(resourceName: "ic-profile"), style: .plain, target: self, action: #selector(profileButtonAction))
        navigationItem.rightBarButtonItem = profileButton
    }
    
    func setupBlurredBackgroundToPanelView() {
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.alpha = 0.8
        
        blurView.translatesAutoresizingMaskIntoConstraints = false
        
        containerPanelView.insertSubview(blurView, at: 0)
        
        containerPanelView.addConstraint(NSLayoutConstraint(item: blurView, attribute: .height, relatedBy: .equal, toItem: containerPanelView, attribute: .height, multiplier: 1.0, constant: 0))
        containerPanelView.addConstraint(NSLayoutConstraint(item: blurView, attribute: .width, relatedBy: .equal, toItem: containerPanelView, attribute: .width, multiplier: 1.0, constant: 0))
        
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "panelSegue" {
            if let destViewController = segue.destination as?   PanelViewController {
                panelViewController = destViewController
                panelViewController?.topViewController = self
            }
        }
    }
}

//MARK: - Interaction
extension MainViewController {
    
    func panGesture(gestureRecognizer: UIPanGestureRecognizer) {
        
        let point = gestureRecognizer.location(in: self.view)
        
        var screenHeight = view.frame.size.height - UIApplication.shared.statusBarFrame.size.height
        
        if let navigationBar = navigationController?.navigationBar {
            if !navigationBar.isHidden {
                screenHeight -= (navigationBar.frame.size.height + 10)
            }
        }
        
        let centerRatio = (-panelViewTopConstraint.constant + originalPanelPosition) / (screenHeight + originalPanelPosition)
        
        print("lastPoint y = ", lastPoint.y)
        print("point y = ", point.y)
        
        if lastPoint.y > point.y {
            //going up
            panelViewGoingUp = true
            print("going up")
        }
        else if lastPoint.y < point.y {
            //going down
            panelViewGoingUp = false
            print("going down")
        }
        
        let centerRatioLimit: CGFloat = panelViewGoingUp ? 0.15 : 0.85
        
        switch gestureRecognizer.state {
        case .changed:
            
            let yDelta = point.y - lastPoint.y
            var newConstant = panelViewTopConstraint.constant + yDelta
            newConstant = newConstant > originalPanelPosition ? originalPanelPosition : newConstant
            newConstant = newConstant < -screenHeight ? -screenHeight : newConstant
            panelViewTopConstraint.constant = newConstant
            
            print("centerRatio = ", centerRatio)
            print("centerRadioLimit = ", centerRatioLimit)
            
        case .ended:
            
            self.panelViewTopConstraint.constant = centerRatio < centerRatioLimit ? self.originalPanelPosition : -screenHeight
            
            //self.panelViewController?.tableview.isScrollEnabled = !(centerRatio < centerRatioLimit)
            
            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [.curveEaseInOut], animations: {
                self.view.layoutIfNeeded()
                
                }, completion: nil)
            
        default:
            break
        }
        
        lastPoint = point
        
    }
    
    func profileButtonAction() {
        performSegue(withIdentifier: "profileSegue", sender: nil)
    }
    
}

//MARK: - Map methods
extension MainViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if !didZoomToUserLocation {
            //mapView.zoomTo(center: userLocation.coordinate)
            didZoomToUserLocation = true
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        if overlay is MKPolygon {
            let polygonView = MKPolygonRenderer(overlay: overlay)
            
            let randomColor = UIColor.randomColor
            
            polygonView.fillColor = randomColor.withAlphaComponent(0.6)
            polygonView.lineWidth = 2.0
            polygonView.lineCap = .round
            polygonView.strokeColor = randomColor
            
            return polygonView
        }
        
        return MKOverlayPathRenderer()
    }
    
    func drawAreasOnMap() {
        mapView.removeOverlays(mapView.overlays)
        
        for area in areas {
            if let points = area.polygon {
                let polygon = MKPolygon(coordinates: points, count: points.count)
                mapView.add(polygon)
            }
        }
        
        if let first = mapView.overlays.first {
            let rect = mapView.overlays.reduce(first.boundingMapRect, {MKMapRectUnion($0, $1.boundingMapRect)})
            mapView.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 50.0, left: 50.0, bottom: 50.0, right: 50.0), animated: true)
        }
    }
}

//MARK: - Requests
extension MainViewController {
    
    func getZones() {
        belugaOverlayView.showView(onView: self.view)
        
        //view.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            //self.view.isUserInteractionEnabled = true
            self.belugaOverlayView.hideView()
        }
    }
    
    public func getMyAreas() {
                
        if let token = Keychain.retriveToken() {
            
            belugaOverlayView.showView(onView: self.view)
            view.isUserInteractionEnabled = false
            
            let parameters = [
                "token": token
            ]
            
            areas = [Area]()
            
        Alamofire.request("\(Webservice.url)/userPolygons", method: .post, parameters: parameters).responseJSON(completionHandler: { [weak self] (response) in
            
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.belugaOverlayView.hideView()
            strongSelf.view.isUserInteractionEnabled = true
            
            switch response.result {
                
            case .success(let value):
                if let jsonArray = JSON(value).array {
                    
                    for areaJson in jsonArray {
                        guard let idArea = areaJson["id_poligono"].int,
                            let name = areaJson["nombre"].string,
                            let arrayPoints = areaJson["puntos"].string,
                            let entryMessage = areaJson["mensaje_entrada"].string,
                            let exitMessage = areaJson["mensaje_salida"].string
                            else {
                            print("invalid json area: ", areaJson)
                            continue
                        }
                        
                        guard let arrayPointsJSON = JSON.parse(arrayPoints).array else {
                            print("cannot parse array of points")
                            continue
                        }
                        var arrayPointsCLLocation = [CLLocationCoordinate2D]()
                        
                        for point in arrayPointsJSON {
                            guard let lat = point["latitud"].double,
                                let lng = point["longitud"].double else {
                                    
                                    print("point = ", point)
                                    print("invalid latitud or longitud")
                                    break
                            }
                            
                            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                            arrayPointsCLLocation.append(coordinate)
                        }
                        
                        let area = Area(id: idArea, name: name, owner: User.sharedInstance, polygon: arrayPointsCLLocation, imageURL: "http://geology.com/world/world-map-clickable.gif", entryMessage: entryMessage, exitMessage: exitMessage)
                        area.friends = [Friend]()
                        
                        strongSelf.areas.append(area)
                    }
                    
                    strongSelf.drawAreasOnMap()
                    strongSelf.panelViewController?.areas = strongSelf.areas
                    strongSelf.panelViewController?.tableView.reloadData()
                }
                else {
                    UIAlertController.presentErrorAlert(inViewController: strongSelf)
                }
                
            case .failure(let error):
                print("error getting user polygons: ", error)
                UIAlertController.presentErrorAlert(inViewController: strongSelf)
            }
            
        })
        
        }
        else {
            dismiss(animated: true, completion: nil)
        }
        
    }
    
    public func getInvitedAreas() {
        belugaOverlayView.showView(onView: self.view)
        view.isUserInteractionEnabled = false
        
        self.belugaOverlayView.hideView()
    }
}
