//
//  AreaDetailViewController.swift
//  Echo
//
//  Created by Luis Mariano Arobes on 17/11/16.
//  Copyright © 2016 Luis Mariano Arobes. All rights reserved.
//

import UIKit
import MapKit

import Alamofire
import SwiftyJSON
import Kingfisher

class AreaDetailViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var ownerImageView: UIImageView!
    @IBOutlet weak var ownerUsernameLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    lazy var belugaOverlayView: EchoOverlayView = {
        let belugaOverlayView = EchoOverlayView()
        return belugaOverlayView
    }()
    
    var selectedArea: Area!
    
    
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
        navigationItem.title = selectedArea.name
        
        tableView.delegate = self
        tableView.dataSource = self
        
        guard let url = URL(string: "http://staticf5b.lavozdelinterior.com.ar/sites/default/files/steve-jobs-morreu-brasil-153927.jpg") else {
            return
        }
        
        let imageResource = ImageResource(downloadURL: url)
        let processor = RoundCornerImageProcessor(cornerRadius: ownerImageView.frame.size.width / 2.0)
        
        ownerImageView.kf.indicatorType = .activity
        ownerImageView.kf.setImage(with: imageResource, options: [.processor(processor)])
        
        ownerImageView.round(cornerRadius: ownerImageView.frame.size.width / 2.0)
        
        ownerUsernameLabel.text = "Owner: luismariano94"
        
        if selectedArea.friends.isEmpty {
            getFriendsOfArea()
        }
    }
    
    //MARK: - Requests
    func getFriendsOfArea() {
        let params = [
            "id_poligono": selectedArea.id
        ]
        
        belugaOverlayView.showView(onView: self.view)
        
        Alamofire.request("\(Webservice.url)/viewFriendsInPolygon", method: .post, parameters: params).responseJSON { [weak self] (response) in
            
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.belugaOverlayView.hideView()
            
            switch response.result {
                
            case .success(let value):
                let json = JSON(value)
                print("json viewFriendsInPolygon ", json)
                
                let images = [
                    "http://static.metacritic.com/images/features/thumbs/yearend_2015_tv_mrrobot.png",
                    "https://media2.giphy.com/media/uPx8gODDgsrYc/200_s.gif",
                    "https://media0.giphy.com/media/NqUG9SuluF3iw/200_s.gif",
                    "https://media2.giphy.com/media/3oEjHWpiVIOGXT5l9m/200_s.gif",
                    "http://images6.fanpop.com/image/photos/39200000/icon-mr-robot-tv-series-39254421-200-200.jpg",
                    "http://www.sweatshirtxy.com/sites/default/files/styles/medium/public/hoodie-images/mr-robot-pullover-sweatshirt-for-men-elliot-pattern93236.jpg?itok=8uODIHkn",
                    "https://i0.wp.com/qumeradigital.files.wordpress.com/2016/07/242071.jpg?resize=200%2C200&ssl=1",
                    "https://67.media.tumblr.com/6496c5dbc00558bc8d36dfb1be4221dd/tumblr_oa4oj9enl81s5slsyo1_500.gif",
                    "https://66.media.tumblr.com/7186091f7d138f9b5ca7ef3e95a8769e/tumblr_nz23bd3xEi1qb9pa3o1_500.gif"
                ]
                for i in 0 ..< images.count {
                    let newFriend = Friend(username: "Friend \(i)", imageURL: images[i], id: i)
                    strongSelf.selectedArea.friends.append(newFriend)
                }
                
                strongSelf.tableView.reloadData()
                
            case .failure(let error):
                print("error calling viewFriendsInPolygon ", error)
                
            }
            
        }
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


//MARK: - TableView Datasource And Delegate
extension AreaDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section == 0 {
            return NSLocalizedString("Friends", comment: "")
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedArea.friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "FriendTableViewCell") as? FriendTableViewCell {
            cell.friend = selectedArea.friends[indexPath.row]
            return cell
        }
        
        let defaultCell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath)
        defaultCell.textLabel?.text = selectedArea.friends[indexPath.row].username
        
        if let url = URL(string: selectedArea.friends[indexPath.row].username),
            let imageView = defaultCell.imageView {
            let imageResource = ImageResource(downloadURL: url)
            let processor = RoundCornerImageProcessor(cornerRadius: imageView.frame.size.width / 2.0)
            imageView.kf.indicatorType = .activity
            imageView.kf.setImage(with: imageResource, options: [.processor(processor), .transition(.fade(0.2))])
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedFriend = selectedArea.friends[indexPath.row]
    }
    
}
