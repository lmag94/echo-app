//
//  PanelViewController.swift
//  Echo
//
//  Created by Luis Mariano Arobes on 10/10/16.
//  Copyright © 2016 Luis Mariano Arobes. All rights reserved.
//

import UIKit

class PanelViewController: UIViewController {

    //MARK: - Outlets
    @IBOutlet weak var topView: UIView! {
        didSet {
            topView.backgroundColor = Color.primaryColor.withAlphaComponent(0.7)
        }
    }
    
    @IBOutlet weak var pullIndicatorView: UIView! {
        didSet {
            pullIndicatorView.round(cornerRadius: 3.0)
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var areas = [Area]()
    
    let myAreasSegmentIndex = 0
    let invitedAreasSegmentIndex = 0
    
    //MARK: - Variables
    var topViewController: MainViewController?
    
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
        setupBlurredBackground()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func setupBlurredBackground() {
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.alpha = 1.0
        
        blurView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.insertSubview(blurView, at: 0)
        
        self.view.addConstraint(NSLayoutConstraint(item: blurView, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: blurView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1.0, constant: 0))
        
    }
    
    //MARK: - Interaction
    @IBAction func createZoneButton(_ sender: UIButton) {
        if let topViewController = topViewController {
            topViewController.performSegue(withIdentifier: "createZoneSegue", sender: nil)
        }
    }
    
    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex  == myAreasSegmentIndex {
            getMyAreas()
        }
        else if sender.selectedSegmentIndex == invitedAreasSegmentIndex {
            getInvitedAreas()
        }
        
    }
    
        
    func getMyAreas() {
        topViewController?.getMyAreas()
    }
    
    func getInvitedAreas() {
        //topViewController?.getInvitedAreas()
        topViewController?.getMyAreas()
    }
}

extension PanelViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return areas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "AreaTableViewCell", for: indexPath) as? AreaTableViewCell {
            cell.area = areas[indexPath.row]
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedArea = areas[indexPath.row]
        
        if let areaDetailVC = storyboard?.instantiateViewController(withIdentifier: "AreaDetailViewController") as? AreaDetailViewController {
            
            print("areaDetailVC")
            areaDetailVC.selectedArea = selectedArea
            topViewController?.navigationController?.pushViewController(areaDetailVC, animated: true)
        }
    }
    
    
}
