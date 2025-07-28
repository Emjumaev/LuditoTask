//
//  SearchPageViewController.swift
//  LuditoTask
//
//  Created by Mekhriddin Jumaev on 24/07/25.
//

import UIKit
import PanModal
import YandexMapsMobile
import CoreLocation

protocol SearchResultsDelegate: AnyObject {
    func didSelectSearchResult(_ result: YMKGeoObject)
    func viewWillDismiss()
    func viewDidDismiss(_ geoObject: YMKGeoObject)
}

class SearchPageViewController: UIViewController {
    
    weak var delegate: SearchResultsDelegate?
    private var viewModel: SearchViewModel!
    
    lazy var searchView: MainSearchView = {
        let view = MainSearchView()
        view.delegate = self
        return view
    }()
    
    lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.separatorViewColor
        return view
    }()
    
    lazy var dragView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.dragGrayColor
        view.layer.cornerRadius = 2
        return view
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SearchPageTableViewCell.self, forCellReuseIdentifier: String(describing: SearchPageTableViewCell.self))
        return tableView
    }()
    
    init(_ viewModel: SearchViewModel, userLocation: CLLocation?) {
        self.viewModel = viewModel
        viewModel.userLocation = userLocation
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        initViews()
        searchView.searchTextField.becomeFirstResponder()
        
        viewModel.onSearchResultsUpdated = { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.viewWillDismiss()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let selectedGeoObject = viewModel.selectedGeoObject {
            delegate?.viewDidDismiss(selectedGeoObject)
        }
    }
    
    private func initViews() {
        view.backgroundColor = .white
        view.addSubview(searchView)
        searchView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(26)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        
        view.addSubview(dragView)
        dragView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.centerX.equalToSuperview()
            make.height.equalTo(4)
            make.width.equalTo(40)
        }
        
        view.addSubview(separatorView)
        separatorView.snp.makeConstraints { make in
            make.top.equalTo(searchView.snp.bottom).offset(14)
            make.left.right.equalToSuperview()
            make.height.equalTo(2)
        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(separatorView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }
}

extension SearchPageViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SearchPageTableViewCell.self), for: indexPath) as? SearchPageTableViewCell else { return UITableViewCell() }
        let result = viewModel.searchResults[indexPath.row]
        cell.configure(with: result)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.searchResults.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedResult = viewModel.searchResults[indexPath.row]
        viewModel.selectedGeoObject = selectedResult.geoObject
        delegate?.didSelectSearchResult(viewModel.selectedGeoObject!)
        self.dismiss(animated: true)
    }
}

extension SearchPageViewController: PanModalPresentable {
    var panScrollable: UIScrollView? {
        return nil
    }
    
    var longFormHeight: PanModalHeight {
        return .maxHeightWithTopInset(40)
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

extension SearchPageViewController: MainSearchViewDelegate {
    func searchFieldChanged(_ searchText: String) {
        viewModel.searchForPlace(searchText)
    }
}
