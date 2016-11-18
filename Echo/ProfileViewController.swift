//
//  ProfileViewController.swift
//  Echo
//
//  Created by Luis Mariano Arobes on 23/10/16.
//  Copyright © 2016 Luis Mariano Arobes. All rights reserved.
//

import UIKit

class ProfileViewController: UITableViewController {

    @IBOutlet weak var profilePictureImageView: UIImageView! {
        didSet {
            profilePictureImageView.layer.cornerRadius = 50
            profilePictureImageView.clipsToBounds = true
            profilePictureImageView.layer.borderWidth = 1.5
            profilePictureImageView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.8).cgColor
        }
    }
    
    //MARK: - Overriden Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Setup
    func setupViews() {
        navigationItem.title = NSLocalizedString("Profile", comment: "")
        
        /*let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGestureRecognizer)*/
        
        let doneBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Done", comment: ""), style: .plain, target: self, action: #selector(doneButtonAction))
        navigationItem.rightBarButtonItem = doneBarButtonItem
    }
    
    
    //MARK: - Interaction
    func doneButtonAction() {
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .white)
        activityIndicatorView.hidesWhenStopped = true
        
        activityIndicatorView.startAnimating()
        navigationItem.rightBarButtonItem?.customView = activityIndicatorView
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {            
            activityIndicatorView.stopAnimating()
            self.navigationItem.rightBarButtonItem?.customView = nil
            let _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changePasswordSegue" {
            print("change Pass")
        }
        else if segue.identifier == "friendsSegue" {
            print("friends")
        }
    }
   

}
