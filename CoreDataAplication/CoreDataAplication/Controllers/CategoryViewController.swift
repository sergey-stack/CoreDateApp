//
//  CategoryViewController.swift
//  CoreDataAplication
//
//  Created by сергей on 11.09.22.
//

import UIKit
import CoreData
class CategoryViewController: UITableViewController {
    var categories = [CategoryModel]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext//получили указатель на апделегат

    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()

    }

    @IBAction func addNewCategory(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)
        alert.addTextField{texField in texField.placeholder = "Category"}
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            if let textField = alert.textFields?.first,//из флерта вытаскиваем все текстфилды и из массива забираю первый
               let text = textField.text,//вытаскиваем текст
               text != "",//проверяем чтобы он не был пустым
               let self = self {//извлекаем селф
                let newCategory = CategoryModel(context: self.context)//создаём модель и в неё вкидываем контекст
                newCategory.name = text//вызывем имя и вкидываем текст
                self .categories.append(newCategory)
               self.saveCategories()
                self.tableView.insertRows(at: [IndexPath(row: self.categories.count - 1, section: 0)], with: .automatic)
                                          }
            
        }
        alert.addAction(cancel)
        alert.addAction(addAction)
        self.present(alert, animated: true)
        
    }
    // MARK: - Table view data source

   

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categories.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let category = categories[indexPath.row]
        cell.textLabel?.text = category.name


        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       performSegue(withIdentifier: "goToItems", sender: nil)
    }
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
       return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete,
           let name = categories[indexPath.row].name {//вытаскиваем имя из категории по индексу
            let request: NSFetchRequest<CategoryModel> = CategoryModel.fetchRequest()
            request.predicate = NSPredicate(format: "name==\(name)")//предикат-это условие по которому будет выполняться реквест
            
            if let categories = try? context.fetch(request) {
                for category in categories {//проходимся по всем категориям и вытаскиваем категорию
                    context.delete(category)
                }
                
                self.categories.remove(at: indexPath.row)//удаляем из массива
                saveCategories()
                tableView.deleteRows(at: [indexPath], with: .fade)//красиво удаляем ячейку
            }
        }
    }
   

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let toDoListVC = segue.destination as? ToDoListViewController,
           let indexPath = tableView.indexPathForSelectedRow
        {
            toDoListVC.selectedCategory = categories[indexPath.row]
            
        }
    }


    private func saveCategories(){
        do {
            try context.save()
        }catch {
            print("Error fetch context")
        }
        tableView.reloadData()
    }

 
private func loadCategories(with request: NSFetchRequest<CategoryModel> = CategoryModel.fetchRequest()){
    do {
        categories = try context.fetch(request)//лезем в контекст вызываем фетч и вкидываем реквест
    } catch {
        print("Error fetch context")
    }
    tableView.reloadData()
}

}
