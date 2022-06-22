//
//  ToDoListTableViewController.swift
//  ToDo
//
//  Created by Chia on 2022/06/09.
//

import UIKit
import CoreData

class ItemTableViewController: UITableViewController, UITextFieldDelegate {
    
    var container: NSPersistentContainer
    var items = [Item]()
    var category: Category
    
    init?(coder: NSCoder, category: Category, container: NSPersistentContainer) {
        self.category = category
        self.container = container
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = category.name
        read()
    }
    
    // MARK: - Add Item
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
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
        update(item)
        tableView.reloadData()
    }
    
    // MARK: - CoreData CRUD
    
    func create(_ title: String) {
        let context = container.viewContext
        let newItem = Item(context: context)
        newItem.title = title
        newItem.done = false
        newItem.category = category
        items.append(newItem)
        container.saveContext()
    }
    
    func read() {
        let context = container.viewContext
        let fetchRequest = Item.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "category = %@", category.objectID)
        do {
            items = try context.fetch(fetchRequest)
            tableView.reloadData()
        } catch {
            print(error)
        }
    }
    
    func update(_ item: Item) {
        item.done.toggle()
        let context = container.viewContext
        let objectID = item.objectID
        do {
            let object = try context.existingObject(with: objectID)
            object.setValue(item.done, forKey: "done")
            container.saveContext()
        } catch {
            print(error)
        }
    }
    
    func delete(_ item: Item) {
        let context = container.viewContext
        context.delete(item)
        container.saveContext()
    }

}
