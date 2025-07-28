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
    
    private let viewModel: AboutViewModel
    
    private lazy var subView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var dragView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.dragGrayColor
        view.layer.cornerRadius = 2
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Le Grande Plaza Hotel"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    
    private lazy var addressLabel: UILabel = {
        let label = UILabel()
        label.text = "Ташкент, ул. Узбекистон Овози, 2"
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = UIColor.addressTitleColor
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "close_icon"), for: .normal)
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var reviewLabel: UILabel = {
        let label = UILabel()
        label.text = "517 оценок"
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = UIColor.addressTitleColor
        return label
    }()
    
    private lazy var makeFavoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.greenButtonColor
        button.layer.cornerRadius = 21
        button.setTitle("Добавить в избранное", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(makeFavorite), for: .touchUpInside)
        return button
    }()
    
    init(viewModel: AboutViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        setupViewModelBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
            make.height.width.equalTo(30)
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
            let starView = UIImageView(image: UIImage(named: "star_fill"))
            starView.frame = CGRect(x: 0, y: 0, width: 16, height: 16)
            starStackView.addArrangedSubview(starView)
        }
        
        let starView = UIImageView(image: UIImage(named: "star_unfill"))
        starView.frame = CGRect(x: 0, y: 0, width: 16, height: 16)
        starStackView.addArrangedSubview(starView)
        
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
    
    private func setupViewModelBindings() {
        viewModel.onUpdateUI = { [weak self] name, address, reviews in
            guard let self = self else {
                return
            }
            print("AboutViewController: Updating UI with name: \(name), address: \(address), reviews: \(reviews)")
            self.titleLabel.text = name
            self.addressLabel.text = address
            self.reviewLabel.text = reviews
        }
        
        viewModel.onShowConfirmationAlert = { [weak self] title, message, confirmAction in
            guard let self = self else {
                return
            }

            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let confirm = UIAlertAction(title: "Подтвердить", style: .default) { _ in confirmAction() }
            let cancel = UIAlertAction(title: "Отмена", style: .destructive, handler: nil)
            alert.addAction(cancel)
            alert.addAction(confirm)
            self.present(alert, animated: true, completion: nil)
        }
        
        viewModel.onShowResultAlert = { [weak self] message in
            guard let self = self else {
                return
            }

            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc private func closeButtonTapped() {
        self.dismiss(animated: true)
    }
    
    @objc private func makeFavorite() {
        viewModel.makeFavorite()
    }
    
    func setGeoObject(_ geoObject: YMKGeoObject) {
        viewModel.setGeoObject(geoObject)
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
