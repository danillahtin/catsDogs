//
//  ProfileViewController.swift
//  UI
//
//  Created by Danil Lahtin on 07.06.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import UIKit
import Core


public final class ProfileViewController: UIViewController {
    private let padding = UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16)
    
    public private(set) weak var profileViewContainerView: UIView!
    public private(set) weak var signInButtonContainerView: UIView!
    public private(set) weak var logoutButtonContainerView: UIView!
    public private(set) weak var profileNameLabel: UILabel!
    public private(set) weak var signInButton: UIButton!
    public private(set) weak var logoutButton: UIButton!
    
    public var onSignIn: () -> () = {}
    
    private var state: ProfileState = .unauthorized
    
    public override func loadView() {
        let profile = buildProfileView()
        let signIn = buildSignInButton()
        let logout = buildLogoutButton()
        
        profile.container.translatesAutoresizingMaskIntoConstraints = false
        signIn.container.translatesAutoresizingMaskIntoConstraints = false
        logout.container.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView(arrangedSubviews: [profile.container, signIn.container, logout.container])
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let view = UIView()
        view.backgroundColor = .white
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            view.leftAnchor.constraint(equalTo: stackView.leftAnchor),
            view.rightAnchor.constraint(equalTo: stackView.rightAnchor),
            view.safeAreaLayoutGuide.topAnchor.constraint(equalTo: stackView.topAnchor),
        ])
        
        self.profileViewContainerView = profile.container
        self.signInButtonContainerView = signIn.container
        self.logoutButtonContainerView = logout.container
        self.profileNameLabel = profile.nameLabel
        self.signInButton = signIn.button
        self.logoutButton = logout.button
        self.view = view
    }
    
    private func buildSignInButton() -> (container: UIView, button: UIButton) {
        let button = UIButton(type: .system)
        button.setTitle("Sign in", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return (UIView.wrapping(button, padding: padding), button)
    }
    
    private func buildLogoutButton() -> (container: UIView, button: UIButton) {
        let button = UIButton(type: .system)
        button.setTitle("Log out", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return (UIView.wrapping(button, padding: padding), button)
    }
    
    private func buildProfileView() -> (container: UIView, nameLabel: UILabel) {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return (UIView.wrapping(label, padding: padding), label)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        signInButton.addTarget(self, action: #selector(onSigninButtonTapped), for: .touchUpInside)
        render(state: state)
    }
    
    public func profileUpdated(state: ProfileState) {
        self.state = state
        
        guard isViewLoaded else {
            return
        }
        
        render(state: state)
    }
    
    private func render(state: ProfileState) {
        switch state {
        case .authorized(let user):
            signInButtonContainerView.isHidden = true
            logoutButtonContainerView.isHidden = false
            profileViewContainerView.isHidden = false
            profileNameLabel.text = user
        case .unauthorized:
            signInButtonContainerView.isHidden = false
            logoutButtonContainerView.isHidden = true
            profileViewContainerView.isHidden = true
        }
    }
    
    @objc
    func onSigninButtonTapped() {
        onSignIn()
    }
}


private extension UIView {
    static func wrapping(_ contentView: UIView, padding: UIEdgeInsets) -> UIView {
        let container = UIView()
        container.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            container.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: -padding.left),
            container.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: padding.right),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: -padding.top),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: padding.bottom),
        ])
        
        return container
    }
}
