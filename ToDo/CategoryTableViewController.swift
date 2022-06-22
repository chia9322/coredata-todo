//
//  CategoryTableViewController.swift
//  ToDo
//
//  Created by Chia on 2022/06/16.
//

import UIKit
import CoreData

class CategoryTableViewController: UITableViewController, UITextFieldDelegate {
    
    var container: NSPersistentContainer!
    var categories = [Category]()

    override func viewDidLoad() {
        super.viewDidLoad()
        read()
    }
    
    // MARK: - Add Category
    @IBAction func addButtonPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alert.title = "Add new category"
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
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        let category = categories[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = category.name
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let category = categories[indexPath.row]
        delete(category)
        categories.remove(at: indexPath.row)
        tableView.reloadData()
    }
    
    // MARK: - Core Data CRUD
    
    func create(_ name: String) {
        let context = container.viewContext
        let newCategory = Category(context: context)
        newCategory.name = name
        categories.append(newCategory)
        container.saveContext()
    }
    
    func read() {
        let context = container.viewContext
        do {
            categories = try context.fetch(Category.fetchRequest())
            tableView.reloadData()
        } catch {
            print("error")
        }
    }
    
    func delete(_ category: Category) {
        let context = container.viewContext
        context.delete(category)
        container.saveContext()
    }
    
    // MARK: - Segue

    @IBSegueAction func showItems(_ coder: NSCoder) -> ItemTableViewController? {
        return ItemTableViewController(coder: coder, category: categories[tableView.indexPathForSelectedRow!.row], container: container)
    }
}
