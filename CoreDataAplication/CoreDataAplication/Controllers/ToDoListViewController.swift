//
//  ToDoListViewController.swift
//  CoreDataAplication
//
//  Created by сергей on 11.09.22.
//

import UIKit
import CoreData

class ToDoListViewController: UITableViewController {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var selectedCategory: CategoryModel? {
        didSet {
            self.title = selectedCategory?.name
            loadItems()
        }
    }

    var itemsArray = [ItemModel]()

    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
    }

    @IBAction func addNewToDo(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add new item", message: "", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Your task"
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            if let texField = alert.textFields?.first,
               let text = texField.text,
               text != "",
               let self = self {
                let newItem = ItemModel(context: self.context)
                newItem.title = text//в тайтл вкидываем текст из текстфилда
                newItem.done = false//устанавливаем фолс потому что мы только что его создали
                newItem.parentCategory = self.selectedCategory
                
                self.itemsArray.append(newItem)
                self.saveItems()
                self.tableView.insertRows(at: [IndexPath(row: self.itemsArray.count - 1, section: 0)], with: .automatic)
            }
        }
        
        alert.addAction(cancel)
        alert.addAction(addAction)
        
        self.present(alert, animated: true)
    }
    // MARK: - Table view data source

 
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        itemsArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)//вытаскиваем ячейку из сториборда
        cell.textLabel?.text = itemsArray[indexPath.row].title
        cell.accessoryType = itemsArray[indexPath.row].done ? .checkmark: .none


        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        itemsArray[indexPath.row].done.toggle()//вытаскиваем айтемс вызываем дан и переворачиваем булевое значение
        self.saveItems()
        tableView.reloadRows(at: [indexPath], with: .fade)//перезагружаем одну ячеку
    }
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let categoryName = selectedCategory?.name,
               let itemName = itemsArray[indexPath.row].title {
                let request: NSFetchRequest<ItemModel> = ItemModel.fetchRequest()
                let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", categoryName)
                let itemPredicate = NSPredicate(format: "title MATCHES %@", itemName)
                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, itemPredicate])
                if let result = try? context.fetch(request) {
                    for object in result {
                        context.delete(object)
                    }
                    itemsArray.remove(at: indexPath.row)
                    saveItems()
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                }
            }
        
        }
    }


   
    private func saveItems() {
        do {
            try context.save()
        } catch {
            print("Error save context")
        }
    }
    
    private func loadItems(with request: NSFetchRequest<ItemModel> = ItemModel.fetchRequest(),
                           predicate: NSPredicate? = nil) {//если предикат не нил
        guard let name = selectedCategory?.name else {//вытаскиваем имя из категории
            return
        }
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", name)//создание предиката
        
        if let predicate = predicate {//то извлекаем его
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, categoryPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        do {
            itemsArray = try context.fetch(request)
        } catch {
            print("Error fetch context")
        }
        tableView.reloadData()
    }
}
extension ToDoListViewController:UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            loadItems()
            searchBar.resignFirstResponder()//завершение ввода
        }else {
            let request: NSFetchRequest<ItemModel> = ItemModel.fetchRequest()
            let searchPredicate = NSPredicate(format: "title CONTAINS %@", searchText)
            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
            loadItems(with: request, predicate: searchPredicate)
        }
    }
    
}
