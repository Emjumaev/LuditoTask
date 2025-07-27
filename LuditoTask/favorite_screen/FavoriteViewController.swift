//
//  FavoriteViewController.swift
//  LuditoTask
//
//  Created by Mekhriddin Jumaev on 25/07/25.
//

import UIKit

class FavoriteViewController: UIViewController {
    
    private var places: [SavedPlace] = []
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(FavoriteTableViewCell.self, forCellReuseIdentifier: String.init(describing: FavoriteTableViewCell.self))
        tableView.separatorStyle = .none
        return tableView
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        let titleLabel = UILabel()
        titleLabel.text = "Мои адреса"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
        titleLabel.sizeToFit()
        
        self.navigationItem.titleView = titleLabel
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchSavedPlaces()
        tableView.reloadData()
    }

    private func fetchSavedPlaces() {
        places = CoreDataManager.shared.fetchPlaces(sortedBy: "name")
    }

}

extension FavoriteViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String.init(describing: FavoriteTableViewCell.self), for: indexPath) as? FavoriteTableViewCell else { return UITableViewCell() }
        let place = places[indexPath.row]
        cell.configure(with: place)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
         if editingStyle == .delete {
             let placeToDelete = places[indexPath.row]
             CoreDataManager.shared.deletePlace(placeToDelete)

             places.remove(at: indexPath.row)

             tableView.deleteRows(at: [indexPath], with: .automatic)
         }
     }
}
