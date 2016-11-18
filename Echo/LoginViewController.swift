//
//  ViewController.swift
//  Echo
//
//  Created by Luis Mariano Arobes on 20/09/16.
//  Copyright © 2016 Luis Mariano Arobes. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Alamofire
import SwiftyJSON

class LoginViewController: UIViewController {

    //MARK: - Outlets
    @IBOutlet weak var belugaLogoTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var belugaLogoCenterYConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var usernameTextField: BlurredUITextField! {
        didSet {
            usernameTextField.alpha = 0.0
            usernameTextField.clearButtonMode = .whileEditing
        }
    }
    
    @IBOutlet weak var emailTextField: BlurredUITextField! {
        didSet {
            emailTextField.alpha = 0.0
            emailTextField.clearButtonMode = .whileEditing
        }
    }
    
    @IBOutlet weak var passwordTextField: BlurredUITextField! {
        didSet {
            passwordTextField.alpha = 0.0
            passwordTextField.isSecureTextEntry = true
            passwordTextField.clearButtonMode = .whileEditing
        }
    }
    
    @IBOutlet weak var confirmPasswordTextField: BlurredUITextField! {
        didSet {
            confirmPasswordTextField.alpha = 0.0
            confirmPasswordTextField.isSecureTextEntry = true
            confirmPasswordTextField.clearButtonMode = .whileEditing
        }
    }
    
    @IBOutlet weak var loginButton: UIButton! {
        didSet {
            loginButton.titleLabel?.numberOfLines = 1;
            loginButton.titleLabel?.adjustsFontSizeToFitWidth = true
            loginButton.backgroundColor = Color.primaryColor
        }
    }
    
    @IBOutlet weak var signUpButton: UIButton!
    
    //MARK: - Constants
    
    let finalYBeluga: CGFloat = 48.0
    
    //MARK: - Variables
    var isShowingSignUp: Bool = false
    var hasDoneAnimation: Bool = false
    
    var mPlayer: AVPlayer!
    var mPlayerView: UIView!
    var avLayer: AVPlayerLayer!
    
    var blurEffectView: UIVisualEffectView!
    
    lazy var belugaOverlayView: EchoOverlayView = {
        let belugaOverlayView = EchoOverlayView()
        return belugaOverlayView
    }()
    
    //MARK: - Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGestureRecognizer)
        
        setupVideoPlayerNotifications()
        setupViews()
        
        if let _ = Keychain.retriveToken() {
            print("token present")
            goToHomeScreen()
        }
        else {
            print("token not present")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        hideNavigationBar()
        mPlayer.play()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        showNavigationBar()
        
        mPlayer.pause()
        removeVideoPlayerNotifications()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Notifications
    func setupVideoPlayerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(appEnteredBackground), name: .UIApplicationDidEnterBackground, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appEnteredForeground), name: .UIApplicationWillEnterForeground, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidReachedEnd), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    func removeVideoPlayerNotifications() {
        NotificationCenter.default.removeObserver(self, name:.UIApplicationDidEnterBackground, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: .UIApplicationWillEnterForeground, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    //MARK: - Interaction
    @IBAction func loginButtonAction(_ sender: UIButton) {
        if !hasDoneAnimation {
            configureViews(forSignUp: false)
        }
        else {
            //Validate Fields
            //Call webservice
            
            if isShowingSignUp {
                performSignUp()
            }
            else {
                performLogin()
            }
            
        }
    }
    
    @IBAction func signUpAction(_ sender: UIButton) {
        //performSegue(withIdentifier: "segueSignUp", sender: nil)
        isShowingSignUp = !isShowingSignUp
        
        if isShowingSignUp {
            signUpButton.setTitle(NSLocalizedString("Back to Login", comment: ""), for: .normal)
            loginButton.setTitle(NSLocalizedString("Sign Up", comment: ""), for: .normal)
            
            configureViews(forSignUp: true)
        }
        else {
            signUpButton.setTitle(NSLocalizedString("Back to Sign Up", comment: ""), for: .normal)
            loginButton.setTitle(NSLocalizedString("Login", comment: ""), for: .normal)
            
            configureViews(forSignUp: false)
        }
    }
    
    @IBAction func facebookButtonAction(_ sender: UIButton) {
        goToHomeScreen()
    }
    
    //MARK: - Actions
    func goToHomeScreen() {
        
        DispatchQueue.main.async {
            [weak self] in
            
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.performSegue(withIdentifier: "homeSegue", sender: nil)
        }
    }
    
    
    //MARK: - Setup
    func configureViews(forSignUp: Bool) {
        
        if !hasDoneAnimation {
            belugaLogoCenterYConstraint.isActive = false
            
            belugaLogoTopConstraint.constant = finalYBeluga
            belugaLogoTopConstraint.isActive = true
        }
        
        emailTextField.isHidden = false
        passwordTextField.isHidden = false
        
        if forSignUp {
            usernameTextField.isHidden = false
            confirmPasswordTextField.isHidden = false
        }
        else {
            usernameTextField.isHidden = false
            confirmPasswordTextField.isHidden = false
        }
        
        UIView.animate(withDuration: 1.5, animations: { [weak self] in
            
            guard let strongSelf = self else {
                return
            }
            
            if !strongSelf.hasDoneAnimation {
                strongSelf.blurEffectView.alpha = 0.9
                strongSelf.view.layoutIfNeeded()
            }
            
            strongSelf.emailTextField.alpha = 1.0
            strongSelf.passwordTextField.alpha = 1.0
            
            if forSignUp {
                strongSelf.usernameTextField.alpha = 1.0
                strongSelf.confirmPasswordTextField.alpha = 1.0
            }
            else {
                strongSelf.usernameTextField.alpha = 0.0
                strongSelf.usernameTextField.removeBlurredBackground()
                
                strongSelf.confirmPasswordTextField.alpha = 0.0
                strongSelf.confirmPasswordTextField.removeBlurredBackground()
            }
            
            }, completion: { [weak self] (successBool) in
                
                guard let strongSelf = self else {
                    return
                }
                
                strongSelf.emailTextField.addBlurredBackground()
                strongSelf.passwordTextField.addBlurredBackground()
                
                if strongSelf.isShowingSignUp {
                    strongSelf.usernameTextField.addBlurredBackground()
                    strongSelf.confirmPasswordTextField.addBlurredBackground()
                    
                }
                
                if !strongSelf.hasDoneAnimation {
                    strongSelf.hasDoneAnimation = true
                }
                
                print("emailTextField frame = ", strongSelf.emailTextField.frame)
        })
    }
    
    func setupViews() {
        let blurEffect = UIBlurEffect(style: .light)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.alpha = 0.0
        
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        view.addSubview(blurEffectView)
        view.sendSubview(toBack: blurEffectView)
        
        setupVideo()
    }
    
    //MARK: - Requests
    func performLogin() {
        guard let email = emailTextField.text,
            let password = passwordTextField.text else {
                UIAlertController.presentErrorAlert(inViewController: self)
                return
        }
        
        let params = [
            "email": email,
            "password": password
        ]
        
        
        belugaOverlayView.showView(onView: self.view)
        Alamofire.request("\(Webservice.url)/login", method: .post, parameters: params).responseJSON(completionHandler: { [weak self] (response) in
            
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.belugaOverlayView.hideView()
            
            switch response.result {
            case .success(let value):
                
                let json = JSON(value)
                
                if let token = json["token"].string,
                    let id = json["id_usuario"].int {
                    
                    let user = User.sharedInstance
                    user.token = token
                    user.id = id
                    
                    Keychain.saveToken(token)
                    Keychain.saveId(id)
                    
                    Pushbots.sharedInstance().setAlias("\(id)");
                    
                    strongSelf.goToHomeScreen()
                }
                else {
                    UIAlertController.presentErrorAlert(message: NSLocalizedString("Invalid Credentials", comment: ""), inViewController: strongSelf, action: nil, completion: nil)
                }
                
            case .failure(let error):
                print("error login: ", error)
            }
        })
    }
    
    func performSignUp() {
        
        guard let email = emailTextField.text,
            let password = passwordTextField.text,
            let username = usernameTextField.text else {
                UIAlertController.presentErrorAlert(inViewController: self)
                return
        }
        
        
        let parameters = [
            "email": email,
            "password": password,
            "username": username,
            "foto": "https://scontent-atl3-1.xx.fbcdn.net/v/t1.0-1/c0.21.160.160/p160x160/14695392_10154248670788051_4344278299541794004_n.jpg?_nc_eui2=v1%3AAeGA1wDB7l3JZZEvJDtghYKc7pfxrav0TzVJMmjTJmmThbxKLYaTkI1LCAXU2TXlQmaAGjm9NQrk8Kzf3-wd4Jigzkc8y712hSO2SIzAJQ7KQw&oh=17038835299b1beae05e360b2f867d56&oe=58B8A515"
        ]
        
        belugaOverlayView.showView(onView: self.view)
        
        Alamofire.request("\(Webservice.url)/registro", method: .post, parameters: parameters).responseJSON { [weak self] (response) in
            
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.belugaOverlayView.hideView()
            
            switch response.result {
            case .success(let value):
                
                let json = JSON(value)
                
                if let _ = json["response"].string {
                    strongSelf.performLogin()
                }
                else {
                    UIAlertController.presentErrorAlert(message: NSLocalizedString("Email already exists", comment: ""), inViewController: strongSelf, action: nil, completion: nil)
                }
                
            case .failure(let error):
                print("error calling registro: ", error)
                UIAlertController.presentErrorAlert(inViewController: strongSelf)
            }
            
        }
        
    }
}

// MARK: – Background video setup methods
extension LoginViewController {
    func appEnteredBackground() {
        mPlayer.pause()
    }
    
    func appEnteredForeground() {
        mPlayer.play()
    }
    
    func playerDidReachedEnd() {
        mPlayer.seek(to: kCMTimeZero)
        mPlayer.play()
    }
    
    func setupVideo() {
        mPlayerView = UIView(frame: self.view.bounds)
        mPlayerView.backgroundColor = UIColor.black
        
        view.addSubview(mPlayerView)
        view.sendSubview(toBack: mPlayerView)
        
        let url = Bundle.main.url(forResource: "cdmx", withExtension: "mp4")
        
        if let url = url {
            mPlayer = AVPlayer(url: url)
            mPlayer.play()
            
            avLayer = AVPlayerLayer(player: mPlayer)
            avLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            avLayer.frame = mPlayerView.bounds
            mPlayerView.layer.addSublayer(avLayer)            
        }
        else {
            print("nil url")
        }
        
    }
}
