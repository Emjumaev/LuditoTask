//
//  FavoriteViewController.swift
//  LuditoTask
//
//  Created by Mekhriddin Jumaev on 25/07/25.
//

import UIKit

class FavoriteViewController: UIViewController {
    
    private var viewModel: FavoriteViewModel!
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.text = "В избранном ничего нет."
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .addressTitleColor
        label.textAlignment = .center
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(FavoriteTableViewCell.self, forCellReuseIdentifier: String(describing: FavoriteTableViewCell.self))
        tableView.separatorStyle = .none
        return tableView
    }()

    init(_ viewModel: FavoriteViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        initViews()
        setupViewModelBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchSavedPlaces()
    }
    
    private func setupNavigationBar() {
        let titleLabel = UILabel()
        titleLabel.text = "Мои адреса"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
        titleLabel.sizeToFit()
        navigationItem.titleView = titleLabel
    }
    
    private func initViews() {
        view.addSubview(messageLabel)
        messageLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupViewModelBindings() {
        viewModel.onPlacesUpdated = { [weak self] places, isEmpty in
            guard let self = self else { return }
            self.tableView.isHidden = isEmpty
            self.tableView.reloadData()
        }
    }
}

extension FavoriteViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfPlaces()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: FavoriteTableViewCell.self), for: indexPath) as? FavoriteTableViewCell else { return UITableViewCell() }
        let place = viewModel.place(at: indexPath.row)
        cell.configure(with: place)
        cell.selectionStyle = .none
        return cell
    }
}

extension FavoriteViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            viewModel.deletePlace(at: indexPath.row)
        }
    }
}
