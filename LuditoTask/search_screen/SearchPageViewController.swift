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
    
    var searchResults: [YMKGeoObject] = []
    weak var delegate: SearchResultsDelegate?
    var userLocation: CLLocation?
    var selectedGeoObject: YMKGeoObject?
    
    private let searchManager: YMKSearchManager
    private var searchSession: YMKSearchSession?

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
        tableView.register(SearchPageTableViewCell.self, forCellReuseIdentifier: String.init(describing: SearchPageTableViewCell.self))
        return tableView
    }()
    
    // MARK: - Initialization
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        searchManager = YMKSearchFactory.instance().createSearchManager(with: .combined)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        searchManager = YMKSearchFactory.instance().createSearchManager(with: .combined)
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        initViews()
        searchView.searchTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.viewWillDismiss()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let selectedGeoObject = selectedGeoObject {
            delegate?.viewDidDismiss(selectedGeoObject)
        }
    }
    
    private func initViews() {
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String.init(describing: SearchPageTableViewCell.self), for: indexPath) as? SearchPageTableViewCell else { return UITableViewCell() }
        let result = searchResults[indexPath.row]
        let info = extractInfo(from: result, userLocation: self.userLocation)
        cell.titleLabel.text = info.name
        cell.addressLabel.text = info.address
        
        if let distance = info.distance {
            if distance >= 1000 {
                let distanceInKm = distance / 1000
                cell.distanceLavel.text = String(format: "%.1f km", distanceInKm)
            } else {
                cell.distanceLavel.text = String(format: "%.0f m", distance)
            }
        } else {
            cell.distanceLavel.text = "-"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedGeoObject = searchResults[indexPath.row]
        delegate?.didSelectSearchResult(selectedGeoObject!)
        self.dismiss(animated: true)
    }
    
    func extractInfo(from geoObject: YMKGeoObject, userLocation: CLLocation?) -> (name: String?, address: String?, distance: Double?) {
    
        var distance: Double? = nil
        if let userLocation = userLocation,
           let targetPoint = geoObject.geometry.first?.point {
            let geoLocation = CLLocation(latitude: targetPoint.latitude, longitude: targetPoint.longitude)
            distance = userLocation.distance(from: geoLocation)
        }
        
        return (geoObject.name,  geoObject.descriptionText, distance)
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

extension SearchPageViewController {
    func searchForPlace(_ searchText: String) {
        // Clear results if the search text is empty
        guard !searchText.isEmpty else {
            searchResults = []
            tableView.reloadData()
            return
        }

        // Cancel any ongoing search session
        searchSession?.cancel()

        // Ensure user location is available
        var userPoint: YMKPoint? = nil
        if let userLocation = userLocation {
            userPoint = YMKPoint(
                latitude: userLocation.coordinate.latitude,
                longitude: userLocation.coordinate.longitude
            )
        } else {
            userPoint = YMKPoint(
                latitude: 41.2995,
                longitude: 69.2401
            )
        }

        // Set up search options
        let searchOptions = YMKSearchOptions()
        searchOptions.searchTypes = [.geo, .biz] // Search for both geographical and business results
        searchOptions.userPosition = userPoint   // Optional: helps server calculate distances

        // Define the response handler
        let responseHandler: (YMKSearchResponse?, Error?) -> Void = { [weak self] (searchResponse, error) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let response = searchResponse {
                    // Extract geo objects from the response
                    self.searchResults = response.collection.children.compactMap { $0.obj }
                    
                    // Optional: Sort results client-side by distance if server sorting is insufficient
                    if let userLocation = self.userLocation {
                        self.searchResults.sort { (a, b) -> Bool in
                            let distA = self.extractInfo(from: a, userLocation: userLocation).distance ?? Double.greatestFiniteMagnitude
                            let distB = self.extractInfo(from: b, userLocation: userLocation).distance ?? Double.greatestFiniteMagnitude
                            return distA < distB
                        }
                    }
                    
                    // Reload the table view with the search results
                    self.tableView.reloadData()
                } else if let error = error {
                    print("Search error: \(error.localizedDescription)")
                }
            }
        }

        // Submit the search request using point geometry
        searchSession = searchManager.submit(
            withText: searchText,
            geometry: YMKGeometry(point: userPoint!),
            searchOptions: searchOptions,
            responseHandler: responseHandler
        )
    }
}

extension SearchPageViewController: MainSearchViewDelegate {
    func searchFieldChanged(_ searchText: String) {
        searchForPlace(searchText)
    }
}
