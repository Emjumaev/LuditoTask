//
//  AboutViewController.swift
//  LuditoTask
//
//  Created by Mekhriddin Jumaev on 27/07/25.
//

import UIKit
import PanModal
import YandexMapsMobile

class AboutViewController: UIViewController {
    
    var geoObject: YMKGeoObject?
        
    lazy var subView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var dragView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.dragGrayColor
        view.layer.cornerRadius = 2
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Le Grande Plaza Hotel"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    
    lazy var addressLabel: UILabel = {
        let label = UILabel()
        label.text = "Ташкент, ул. Узбекистон Овози, 2"
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = UIColor.addressTitleColor
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "close_icon"), for: .normal)
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }()

    lazy var reviewLabel: UILabel = {
        let label = UILabel()
        label.text = "517 оценок"
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = UIColor.addressTitleColor
        return label
    }()
    
    lazy var makeFavoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.greenButtonColor
        button.layer.cornerRadius = 21
        button.setTitle("Добавить в избранное", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(makeFavorite), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        initViews()
    }
    
    private func initViews() {
        view.addSubview(subView)
        subView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        subView.addSubview(dragView)
        dragView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.centerX.equalToSuperview()
            make.width.equalTo(40)
            make.height.equalTo(4)
        }
        
        subView.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(30)
            make.height.width.equalTo(24)
        }
        
        subView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.left.equalToSuperview().offset(16)
            make.right.equalTo(closeButton.snp.left).offset(-10)
        }
        
        subView.addSubview(addressLabel)
        addressLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(16)
            make.right.equalTo(closeButton.snp.left).offset(-10)
        }
        
        let starStackView = UIStackView()
        starStackView.spacing = 5
        starStackView.axis = .horizontal
        starStackView.distribution = .equalSpacing
        
        for _ in 1...4 {
            let startView = UIImageView(image: UIImage(named: "star_fill"))
            startView.frame = CGRect(x: 0, y: 0, width: 16, height: 16)
            starStackView.addArrangedSubview(startView)
        }
        
        let startView = UIImageView(image: UIImage(named: "star_unfill"))
        startView.frame = CGRect(x: 0, y: 0, width: 16, height: 16)
        starStackView.addArrangedSubview(startView)
        
        subView.addSubview(starStackView)
        starStackView.snp.makeConstraints { make in
            make.top.equalTo(addressLabel.snp.bottom).offset(15)
            make.left.equalTo(addressLabel)
            make.width.equalTo(100)
        }
        
        subView.addSubview(reviewLabel)
        reviewLabel.snp.makeConstraints { make in
            make.left.equalTo(starStackView.snp.right).offset(5)
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalTo(starStackView)
        }
        
        subView.addSubview(makeFavoriteButton)
        makeFavoriteButton.snp.makeConstraints { make in
            make.top.equalTo(starStackView.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(16)
            make.height.equalTo(42)
            make.width.equalTo(220)
        }
    }
    
    @objc func closeButtonTapped() {
        self.dismiss(animated: true)
    }
    
    @objc func makeFavorite() {
        if let geoObject = geoObject {
            showAddToFavoritesAlert(geoObject.name ?? "", on: self)
        }
    }
    
    func showAddToFavoritesAlert(_ address: String, on viewController: UIViewController) {
        let alert = UIAlertController(
            title: "Добавить адрес в избранное",
            message: address,
            preferredStyle: .alert
        )
        
        let confirmAction = UIAlertAction(title: "Подтвердить", style: .default) { _ in
            // Действие при подтверждении
            print("Адрес добавлен в избранное: \(address)")
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .destructive, handler: nil)
        
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        
        viewController.present(alert, animated: true, completion: nil)
    }
    
    func setGeoObject(_ geoObject: YMKGeoObject) {
        self.geoObject = geoObject
        titleLabel.text = geoObject.name
        addressLabel.text = geoObject.descriptionText
    }
}

extension AboutViewController: PanModalPresentable {
    var panScrollable: UIScrollView? {
        return nil
    }
    
    var longFormHeight: PanModalHeight {
        return .contentHeight(200)
    }
    
    var cornerRadius: CGFloat {
        return 8.0
    }
    
    var showDragIndicator: Bool {
        return false
    }
    
    var panModalBackgroundColor: UIColor {
        return UIColor.black.withAlphaComponent(0.2)
    }
}
