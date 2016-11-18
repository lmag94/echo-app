//
//  SelectFriendsViewController.swift
//  Echo
//
//  Created by Luis Mariano Arobes on 02/11/16.
//  Copyright © 2016 Luis Mariano Arobes. All rights reserved.
//

import UIKit
import Kingfisher

class SelectFriendsViewController: UIViewController {

    //MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = self
            collectionView.delegate = self
        }
    }
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    @IBOutlet weak var selectFriendsLabel: UILabel!
    
    //MARK: - Constants
    
    //MARK: - Variables
    lazy var belugaOverlayView: EchoOverlayView = {
        let belugaOverlayView = EchoOverlayView()
        return belugaOverlayView
    }()
    
    var friends = [Friend]()
    var selectedFriends = [Friend]() {
        didSet {
            if selectedFriends.isEmpty {
                selectFriendsLabel.isHidden = false
                navigationItem.rightBarButtonItem?.isEnabled = false
            }
            else {
                selectFriendsLabel.isHidden = true
                navigationItem.rightBarButtonItem?.isEnabled = true
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = NSLocalizedString("Select Friends", comment: "")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Next", comment: ""), style: .done, target: self, action: #selector(nextButtonAction))
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        getFriends()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: - Interaction
    
    func nextButtonAction() {
        
        _ = navigationController?.popToRootViewController(animated: true)
        
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

//MARK: - Requests
extension SelectFriendsViewController {
    
    func getFriends() {
        friends = [Friend]()
        
        belugaOverlayView.showView(onView: self.view)
        
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
            friends.append(newFriend)
        }
        
        //view.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            //self.view.isUserInteractionEnabled = true
            self.belugaOverlayView.hideView()
            self.tableView.reloadData()
        }        
    }
    
}


//MARK: - UITableViewDelegate Methods
extension SelectFriendsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let cellAtIndexPath = tableView.cellForRow(at: indexPath) else {
            return
        }
        
        let friend = friends[indexPath.row]
        
        friend.selected = !friend.selected
        print("1")
        
        if  friend.selected == true {
            cellAtIndexPath.accessoryType = .checkmark
            selectedFriends.append(friend)
            collectionView.reloadData()
        }
        else {
            cellAtIndexPath.accessoryType = .none
            
            var foundIndex = -1
            for i in 0 ..< selectedFriends.count {
                if friend.id == selectedFriends[i].id {
                    foundIndex = i
                    break
                }
            }
            
            if foundIndex != -1 {
                selectedFriends.remove(at: foundIndex)
                collectionView.reloadData()
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let friend = friends[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "FriendTableViewCell", for: indexPath) as? FriendTableViewCell {
            cell.accessoryType = friend.selected == true ? .checkmark : .none
            
            cell.friend = friend
            return cell
        }        
        
        return UITableViewCell()
    }
}

//MARK: - UICollectionViewDelegate Methods
extension SelectFriendsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedFriends.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let friend = selectedFriends[indexPath.row]
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectedFriendCollectionViewCell", for: indexPath) as? SelectedFriendCollectionViewCell {
            
            cell.friend = friend
            cell.round(cornerRadius: cell.frame.size.width / 2.0)
            cell.layer.borderWidth = 1.0
            cell.layer.borderColor = Color.primaryColor.cgColor
            
            return cell
        }
        
        return UICollectionViewCell()
    }
    
}
