import UIKit

class FavoriteTableViewCell: UITableViewCell {
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.grayBorderClor.cgColor
        view.layer.shadowColor = UIColor(hex: "#DCDCDC").withAlphaComponent(0.4).cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowRadius = 3
        view.layer.masksToBounds = false
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
        label.numberOfLines = 3
        return label
    }()
    
    lazy var locationIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "favorite_location")?.withRenderingMode(.alwaysOriginal)
        return imageView
    }()
    

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initViews() {
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        
        let middleView = UIView()
        middleView.addSubview(titleLabel)
        middleView.addSubview(addressLabel)
        
        containerView.addSubview(middleView)
        middleView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
        
        addressLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.left.equalToSuperview()
            make.right.equalToSuperview().offset(-60)
            make.bottom.equalToSuperview()
        }
        
        containerView.addSubview(locationIcon)
        locationIcon.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.height.width.equalTo(32)
        }
    }
    
    func configure(with place: SavedPlace) {
        titleLabel.text = place.name
        addressLabel.text = place.address
    }
}

