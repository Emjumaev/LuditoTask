//
//  MainSearchView.swift
//  LuditoTask
//
//  Created by Mekhriddin Jumaev on 24/07/25.
//

import UIKit
import SnapKit

protocol MainSearchViewDelegate: AnyObject {
    func searchFieldChanged(_ searchText: String)
}

class MainSearchView: UIView {
    
    weak var delegate: MainSearchViewDelegate?
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.searchBackColor
        view.layer.cornerRadius = 10
        return view
    }()
    
    lazy var searchIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "icon_search")
        return imageView
    }()
    
    lazy var searchTextField: UITextField = {
        let textField = UITextField()
        
        let customFont = UIFont.systemFont(ofSize: 16, weight: .bold)
        
        textField.font = customFont
        textField.attributedPlaceholder = NSAttributedString(
            string: "Поиск",
            attributes: [
                .foregroundColor: UIColor.black,
                .font: customFont
            ]
        )
        
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        let clearButton = UIButton(type: .custom)
        clearButton.setImage(UIImage(named: "search_clear_icon"), for: .normal)
        clearButton.tintColor = .gray
        clearButton.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        clearButton.addTarget(self, action: #selector(clearTextField), for: .touchUpInside)
        
        textField.rightView = clearButton
        textField.rightViewMode = .whileEditing
        textField.spellCheckingType = .no
        textField.autocorrectionType = .no
        textField.tintColor = .black
        
        return textField
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStyle()
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func clearTextField() {
        searchTextField.text = ""
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        let currentText = textField.text ?? ""
        
        searchTextField.rightView?.isHidden = currentText.isEmpty
        
        delegate?.searchFieldChanged(currentText)
    }
    
    private func setupStyle() {
        self.backgroundColor = .white
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor(red: 241/255, green: 241/255, blue: 241/255, alpha: 1.0).cgColor
        self.layer.cornerRadius = 16
        self.layer.masksToBounds = true
    }
    
    private func initViews() {
        self.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.left.top.equalToSuperview().offset(8)
            make.right.bottom.equalToSuperview().offset(-8)
        }
        
        containerView.addSubview(searchIcon)
        searchIcon.snp.makeConstraints { make in
            make.height.width.equalTo(24)
            make.left.top.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().offset(-12)
        }
        
        containerView.addSubview(searchTextField)
        searchTextField.snp.makeConstraints { make in
            make.left.equalTo(searchIcon.snp.right).offset(12)
            make.top.bottom.equalTo(containerView)
            make.right.equalToSuperview().offset(-12)
        }
    }
}
