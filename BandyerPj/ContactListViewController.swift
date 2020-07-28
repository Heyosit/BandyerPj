//
//  ViewController.swift
//  BandyerPj
//
//  Created by Alessio Perrotti on 27/07/2020.
//  Copyright © 2020 Alessio Perrotti. All rights reserved.
//

import UIKit

final class ContactListViewController: UIViewController {

// MARK: UI
    
    private var contactListTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.showsVerticalScrollIndicator = false
        tableView.tableHeaderView = UIView(frame: CGRect(x: .zero, y: .zero, width: .zero, height: CGFloat.leastNormalMagnitude))
        
        return tableView
    }()
    
// MARK: Data
    
    var contactListMock: [Contact] = [
        Contact(name: "Alessio", number: "333292932"),
        Contact(name: "Luca", number: "111345332"),
        Contact(name: "Aldo", number: "2345634534"),
        Contact(name: "Marco", number: "56467433"),
        Contact(name: "Giovanni", number: "65747345345"),
        Contact(name: "Gennaro", number: "34534226"),
        Contact(name: "Mariano", number: "7534535"),
        Contact(name: "Paolo", number: "7456456")
    ]
    
// MARK: Setup
    
    override func loadView() {
        super.loadView()
        setupLayout()
    }
    
    private func setupLayout() {
        view.addSubview(contactListTableView)
        
        NSLayoutConstraint.activate([
            
            contactListTableView.topAnchor.constraint(equalTo: view.topAnchor),
            contactListTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contactListTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contactListTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    private func setup() {
        setupTableView()
    }
    
    private func setupTableView() {
        contactListTableView.delegate = self
        contactListTableView.dataSource = self
        contactListTableView.register(ContactInfoTableViewCell.self, forCellReuseIdentifier: ContactInfoTableViewCell.reuseIdentifier)
    }

}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension ContactListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactListMock.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ContactInfoTableViewCell.reuseIdentifier, for: indexPath) as! ContactInfoTableViewCell
        cell.config(contact: contactListMock[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    
}

