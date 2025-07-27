//
//  SearchPageTableViewCell.swift
//  LuditoTask
//
//  Created by Mekhriddin Jumaev on 24/07/25.
//

import UIKit

class SearchPageTableViewCell: UITableViewCell {
    
    lazy var pinIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "search_pinpoint")
        return imageView
    }()
    
    lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.separatorViewColor
        return view
    }()
    
    lazy var middleView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Le Grande Plaza Hotel"
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    
    lazy var addressLabel: UILabel = {
        let label = UILabel()
        label.text = "Ташкент, ул. Узбекистон Овози, 2"
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = UIColor.addressTitleColor
        return label
    }()
    
    lazy var distanceLavel: UILabel = {
        let label = UILabel()
        label.text = "36 м"
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textAlignment = .right
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initViews() {
        contentView.addSubview(pinIcon)
        pinIcon.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(16)
            make.height.width.equalTo(32)
        }
        
        contentView.addSubview(separatorView)
        separatorView.snp.makeConstraints { make in
            make.top.equalTo(pinIcon.snp.bottom).offset(26)
            make.height.equalTo(2)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        middleView.addSubview(titleLabel)
        middleView.addSubview(addressLabel)
        
        contentView.addSubview(middleView)
        middleView.snp.makeConstraints { make in
            make.left.equalTo(pinIcon.snp.right).offset(12)
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
        
        contentView.addSubview(distanceLavel)
        distanceLavel.snp.makeConstraints { make in
            make.top.equalTo(middleView)
            make.right.equalToSuperview().offset(-16)
            make.width.equalTo(100)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.left.equalToSuperview()
            make.right.equalTo(distanceLavel.snp.left).offset(-10)
        }
        
        addressLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(2)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
}
