//
//  ToDoListTableViewController.swift
//  ToDo
//
//  Created by Chia on 2022/06/09.
//

import UIKit
import CoreData

class ToDoListTableViewController: UITableViewController, UITextFieldDelegate {
    
    var items = [Item]()

    override func viewDidLoad() {
        super.viewDidLoad()
        items = read()
        tableView.reloadData()
    }
    
    // MARK: - Add Item
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        showAddAlert()
    }
    
    func showAddAlert() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alert.title = "Add new item"
        alert.addTextField { textField in
            textField.delegate = self
        }
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { action in
            guard let itemTitle = alert.textFields?.first?.text else { return }
            self.create(itemTitle)
            self.tableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
        let item = items[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = item.title
        cell.contentConfiguration = content
        cell.accessoryType = item.done ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        delete(item)
        items.remove(at: indexPath.row)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        item.done.toggle()
        update(item)
        tableView.reloadData()
    }
    
    // MARK: - CoreData CRUD
    
    func create(_ title: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let newItem = Item(context: managedContext)
        newItem.title = title
        newItem.done = false
        items.append(newItem)
        appDelegate.saveContext()
    }
    
    func read() -> [Item] {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return [] }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
        do {
            let items = try managedContext.fetch(fetchRequest) as! [Item]
            return items
        } catch {
            print(error)
            return []
        }
    }
    
    func update(_ item: Item) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let objectID = item.objectID
        do {
            let object = try managedContext.existingObject(with: objectID)
            object.setValue(item.done, forKey: "done")
            appDelegate.saveContext()
        } catch {
            print(error)
        }
    }
    
    func delete(_ item: Item) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        managedContext.delete(item)
        appDelegate.saveContext()
    }

}
