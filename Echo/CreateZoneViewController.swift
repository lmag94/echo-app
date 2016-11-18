//
//  CreateZoneViewController.swift
//  Echo
//
//  Created by Luis Mariano Arobes on 24/10/16.
//  Copyright © 2016 Luis Mariano Arobes. All rights reserved.
//

import UIKit
import MapKit
import Alamofire
import SwiftyJSON

class CreateZoneViewController: UIViewController {

    //MARK: - Outlets
    @IBOutlet weak var zoneNameTextField: UITextField! {
        didSet {
            zoneNameTextField.delegate = self
        }
    }
    
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.mapType = .hybrid
            mapView.delegate = self
        }
    }
    
    @IBOutlet weak var blurredButtonBackgroundView: UIView! {
        didSet {
            blurredButtonBackgroundView.clipsToBounds = true
            blurredButtonBackgroundView.layer.cornerRadius = 4.0
        }
    }
    
    @IBOutlet weak var drawingButton: UIButton!
    
    @IBOutlet weak var mapViewConstraintToTop: NSLayoutConstraint!
    @IBOutlet weak var mapViewConstraintTopToZoneName: NSLayoutConstraint!
    @IBOutlet weak var heightZoneTextFieldConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var tempImageView: UIImageView!
    
    //MARK: - Variables
    var isDrawing = false {
        didSet {
            
            if isDrawing {
                mapView.removeOverlays(mapView.overlays)
                pointsOfDrawing = [CGPoint]()
                tempImageView.image = nil
                mainImageView.image = nil
                
                mapViewConstraintToTop.constant = 0
                heightZoneTextFieldConstraint.constant = 0.0
                mapViewConstraintToTop.isActive = true
                mapViewConstraintTopToZoneName.isActive = false
            }
            else {
                heightZoneTextFieldConstraint.constant = 48.0
                mapViewConstraintToTop.isActive = false
                mapViewConstraintTopToZoneName.isActive = true
            }
            
            UIView.animate(withDuration: 0.3, animations: { 
                self.view.layoutIfNeeded()
                }) { (success) in
                    
                self.mapView.isUserInteractionEnabled = !self.isDrawing
            }
            
            
            var title = isDrawing ? NSLocalizedString("Stop Drawing", comment: "") : NSLocalizedString("Start Drawing", comment: "")
            
            if !isDrawing && pointsOfDrawing.count > 0{
                
                title = NSLocalizedString("Redraw Zone", comment: "")
            }
            
            drawingButton.setTitle(title, for: .normal)
        }
    }
    
    var pointsOfDrawing: [CGPoint] = [CGPoint]() {
        didSet {
            if pointsOfDrawing.isEmpty {
                didCreatePolygon = false
            }
        }
    }
    
    var lastPoint = CGPoint.zero
    var drawingColor = Color.primaryColor
    var brushWidth: CGFloat = 5.0
    var swiped = false
    
    var didCreatePolygon = false {
        didSet {
            navigationItem.rightBarButtonItem?.isEnabled = (didCreatePolygon && didSetName)
        }
    }
    
    var didSetName = false {
        didSet {
            navigationItem.rightBarButtonItem?.isEnabled = (didCreatePolygon && didSetName)
        }
    }
    
    var didZoomToUserLocation = false
    
    lazy var belugaOverlayView: EchoOverlayView = {
        let belugaOverlayView = EchoOverlayView()
        return belugaOverlayView
    }()
    
    //MARK: - Overriden Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Setup
    func setupViews() {
        navigationItem.title = NSLocalizedString("New Zone", comment: "")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Next", comment: ""), style: .done, target: self, action: #selector(nextButtonAction))
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        zoneNameTextField.addTarget(self, action: #selector(textFieldChanged(textField:)), for: UIControlEvents.editingChanged)
    }
    
    //MARK: - Interaction
    @IBAction func drawButtonAction(_ sender: UIButton) {
        isDrawing = !isDrawing
        hideKeyboard()
    }
    
    func nextButtonAction() {
        let alert = UIAlertController(title: NSLocalizedString("Set A Message", comment: ""), message: NSLocalizedString("Set messages", comment: ""), preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default, handler: {(action) in
            
            guard let entryMessageTextField = alert.textFields?[0] else {
                return
            }
            
            guard let exitMessageTextField = alert.textFields?[1] else {
                return
            }
            
            print("entry message = ", entryMessageTextField.text ?? "no entry message")
            print("exit message = ", exitMessageTextField.text ?? "no exit message")
            
            self.uploadPolygon(entryMessage: entryMessageTextField.text ?? "", exitMessage: exitMessageTextField.text ?? "")
            
        })
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: { action in
            
            alert.dismiss(animated: true, completion: nil)
            
        })
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        alert.addTextField { (textField) in
            textField.placeholder = NSLocalizedString("Entry Message", comment: "")
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = NSLocalizedString("Exit Message", comment: "")
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

//MARK: - Drawing methods
extension CreateZoneViewController {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if isDrawing {
            swiped = false
            
            if let touch = touches.first {
                lastPoint = touch.location(in: self.view)
                pointsOfDrawing.append(lastPoint)
            }
        }
    }
    
    func drawLine(fromPoint: CGPoint, toPoint: CGPoint) {
        
        UIGraphicsBeginImageContext(view.frame.size)
        let context = UIGraphicsGetCurrentContext()
        tempImageView.image?.draw(in: CGRect(x: 0.0, y: 0.0, width: view.frame.size.width, height: view.frame.size.height))
        
        
        context?.move(to: fromPoint)
        context?.addLine(to: toPoint)
        
        context?.setLineCap(CGLineCap.round)
        context?.setLineWidth(brushWidth)
        context?.setStrokeColor(drawingColor.cgColor)
        context?.setBlendMode(CGBlendMode.normal)
        
        context?.strokePath()
        
        tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        tempImageView.alpha = 1.0
        
        UIGraphicsEndImageContext()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if isDrawing {
            swiped = true
            
            if let touch = touches.first {
                let currentPoint = touch.location(in: view)
                pointsOfDrawing.append(currentPoint)
            
                drawLine(fromPoint: lastPoint, toPoint: currentPoint)
            
                lastPoint = currentPoint
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if isDrawing {
            
            if !swiped {
                drawLine(fromPoint: lastPoint, toPoint: lastPoint)
            }
            
            UIGraphicsBeginImageContext(mainImageView.frame.size)
            
            mainImageView.image?.draw(in: CGRect(x: 0.0, y: 0.0, width: view.frame.size.width, height: view.frame.size.height), blendMode: CGBlendMode.normal, alpha: 1.0)
            
            tempImageView.image?.draw(in: CGRect(x: 0.0, y: 0.0, width: view.frame.size.width, height: view.frame.size.height), blendMode: CGBlendMode.normal, alpha: 1.0)
            
            mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
            
            tempImageView.image = nil
            
            drawPolygonOnMap()
            
            isDrawing = false
        }
    }
    
    func drawPolygonOnMap() {
        
        tempImageView.image = nil
        mainImageView.image = nil
        
        var points = [CLLocationCoordinate2D]()
        
        for point in pointsOfDrawing {
            points.append(translatePointToMapCoordinates(point: point))
        }
        
        let polygon = MKPolygon(coordinates: &points, count: points.count)
        mapView.add(polygon)
        didCreatePolygon = true
    }
    
    func translatePointToMapCoordinates(point: CGPoint) -> CLLocationCoordinate2D {
        return mapView.convert(point, toCoordinateFrom: self.view)
    }
}

//MARK: - MapKit delegate methods
extension CreateZoneViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        if overlay is MKPolygon {
            let polygonView = MKPolygonRenderer(overlay: overlay)
            
            polygonView.fillColor = Color.primaryColor.withAlphaComponent(0.7)
            polygonView.lineWidth = brushWidth
            polygonView.lineCap = .round
            polygonView.strokeColor = drawingColor
            
            return polygonView
        }
        
        return MKOverlayPathRenderer()
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        hideKeyboard()
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
        if !didZoomToUserLocation {
            didZoomToUserLocation = true
            mapView.zoomTo(center: userLocation.coordinate, animated: false)
        }
        
    }
}

//MARK: - TextField delegate methods
extension CreateZoneViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        hideKeyboard()
        return false
    }
    
    func textFieldChanged(textField: UITextField) {
        if let text = textField.text {
            let newText = text.replacingOccurrences(of: " ", with: "")
            didSetName = !newText.isEmpty
            
        }
        
        navigationItem.title = didSetName ? textField.text : NSLocalizedString("New Zone", comment: "")
    }
}

//MARK: - Requests 
extension CreateZoneViewController {
    func uploadPolygon(entryMessage: String, exitMessage: String) {
        if let token = Keychain.retriveToken(),
            let zoneName = zoneNameTextField.text {
            
            var points = "["
            for i in 0 ..< pointsOfDrawing.count {
                
                let point = pointsOfDrawing[i]
                let coordinate = translatePointToMapCoordinates(point: point)
                points += "{\"latitud\": \(coordinate.latitude), \"longitud\": \(coordinate.longitude)}"
                
                if i < (pointsOfDrawing.count - 1) {
                    points += ","
                }
                
            }
            
            points += "]"
            
            print("points = ", points)
            let params = [
                "token": token,
                "nombre": zoneName,
                "puntos": points,
                "image": "http://static.metacritic.com/images/features/thumbs/yearend_2015_tv_mrrobot.png",
                "mensaje_entrada": entryMessage,
                "mensaje_salida": exitMessage
            ]
            
            belugaOverlayView.showView(onView: self.view)
            
            Alamofire.request("\(Webservice.url)/createPolygon", method: .post, parameters: params).responseJSON(completionHandler: { (response) in
                
                self.belugaOverlayView.hideView()
                
                switch response.result {
                    
                case .success(let value):
                    let json = JSON(value)
                    print("json createPolygon = ", json)
                    self.performSegue(withIdentifier: "selectFriendsSegue", sender: nil)
                    
                case .failure(let error):
                    print("error creating polygon: ", error)
                    UIAlertController.presentErrorAlert(inViewController: self)
                }
            })
            
            
        }
    }
}

