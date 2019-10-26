//
//  ViewController.swift
//  AddAndEditRow
//
//  Created by Jose Francisco Catalá Barba on 26/10/2019.
//  Copyright © 2019 Jose Francisco Catalá Barba. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    // MARK: Constants
    let Identifier = "Cell"
    let Placeholder = "Enter the description"
    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnAddRow: UIBarButtonItem!
    // MARK: Ivars
    var dataArray: Array<String> = ["Row one", "Row two", "Row Three"]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: .zero)
        let refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl
        tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
    }
    
    // MARK: - Actions
    @IBAction func addNewRowDidTap(_ sender: Any) {
        btnAddRow.isEnabled = false
        dataArray.append(Placeholder)
        configureEditCell()
    }
    
    @objc func addDidTap(_ sender: Any) {
        self.view.endEditing(true)
    }
    
}

//MARK: - UITableView datasource
extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifier, for: indexPath)
        let text = dataArray[indexPath.row]
        if text == Placeholder {
            let addButton = UIButton(type: .contactAdd) as UIButton
            addButton.addTarget(self, action:#selector(addDidTap(_:)), for: .touchUpInside)
            cell.accessoryView = addButton as UIView
        }
        else {
            cell.textLabel?.text = dataArray[indexPath.row]
            cell.accessoryView = .none
        }
        return cell
    }
}

// MARK: - UITableView delegate
extension ViewController: UITableViewDelegate {
    
     func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete, dataArray.count > indexPath.row {
            dataArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        }
        else {
            tableView.reloadData()
        }
        self.view.endEditing(true)
        btnAddRow.isEnabled = true
    }
    
    @objc func refresh(refreshControl: UIRefreshControl) {
        tableView.reloadData()
        btnAddRow.isEnabled = true
        self.view.endEditing(true)
        refreshControl.endRefreshing()
    }
}

// MARK: - UITextField delegate
extension ViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //Double check if the user did delete the row before end Editing was performed
        if textField.tag >= dataArray.count { return }
        dataArray.remove(at: dataArray.count - 1)
        //Check if textField is nil
        guard let text = textField.text else { return }
        //Check if textField has no text
        if text.count == 0 { return }
        //Add the text to the array
        dataArray.append(text)
        //Remove the textField from the view
        textField.removeFromSuperview()
        //Reload the table to show the results
        tableView.reloadData()
        //Reactivate the add button
        btnAddRow.isEnabled = true
    }
}

// MARK: - Private functions
extension ViewController {
    
    // Configure the cell to add a UITextField to enter the text
    private func configureEditCell(){
        let indexPath = IndexPath(row: dataArray.count - 1, section: 0)
        //Insert a new row at the bottom of the table
        tableView.beginUpdates()
        tableView.insertRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
        //Get a cell by its index
        let cell = tableView.cellForRow(at: indexPath)
        if let frame = cell?.textLabel?.frame {
            //Create the UITextField with the same frame that the default UILable
            let txt = UITextField(frame: frame)
            txt.placeholder = Placeholder
            txt.delegate = self
            txt.tag = indexPath.row //Added but not in use
            txt.becomeFirstResponder()
            cell?.addSubview(txt)
            //In case it is a reusabled cell
            cell?.textLabel?.text = ""
            txt.translatesAutoresizingMaskIntoConstraints = true
        }
    }
}

