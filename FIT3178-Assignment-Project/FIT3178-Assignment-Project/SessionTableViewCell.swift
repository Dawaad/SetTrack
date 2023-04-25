//
//  SessionTableViewCell.swift
//  FIT3178-Assignment-Project
//
//  Created by Jared Tucker on 20/4/2023.
//

import UIKit

class SessionTableViewCell: UITableViewCell, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var nestedTableView: UITableView!

    var items: [String] = []

    override func awakeFromNib() {
        super.awakeFromNib()

        // Configure the nested table view
        nestedTableView.dataSource = self
        nestedTableView.delegate = self
        nestedTableView.register(UITableViewCell.self, forCellReuseIdentifier: "NestedCell")
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NestedCell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row]
        return cell
    }
}
