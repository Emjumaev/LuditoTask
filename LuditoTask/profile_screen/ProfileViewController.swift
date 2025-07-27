//
//  ProfileViewController.swift
//  LuditoTask
//
//  Created by Mekhriddin Jumaev on 27/07/25.
//

import UIKit

class ProfileViewController: UIViewController {
    
    lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.text = "Эта страница находится в стадии разработки."
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .addressTitleColor
        label.textAlignment = .center
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
        setupConstraints()
    }
    
    private func initViews() {
        let titleLabel = UILabel()
        titleLabel.text = "Профиль"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
        titleLabel.sizeToFit()
        self.navigationItem.titleView = titleLabel
        
        view.backgroundColor = .white
    }
    
    private func setupConstraints() {
        view.addSubview(messageLabel)
        messageLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
    }

}
