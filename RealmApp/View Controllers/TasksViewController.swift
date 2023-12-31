//
//  TasksViewController.swift
//  RealmApp
//
//  Created by Александр Мамлыго on /87/2566 BE.
//

import UIKit
import RealmSwift

class TasksViewController: UITableViewController {

    var taskList: TaskList!
    
    private var completedTasks: Results<Task>!
    private var currentTasks: Results<Task>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = taskList.name
        
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonPressed)
        )
        navigationItem.rightBarButtonItems = [addButton, editButtonItem]
        currentTasks = taskList.tasks.where {
            $0.isComplete == false
        }
        completedTasks = taskList.tasks.filter("isComplete = true")
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? currentTasks.count : completedTasks.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "CURRENT TASKS" : "COMPLETED TASKS"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "task", for: indexPath)
        var content = cell.defaultContentConfiguration()
        let task = indexPath.section == 0 ? currentTasks[indexPath.row] : completedTasks[indexPath.row]
        content.text = task.name
        content.secondaryText = task.note
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let task = indexPath.section == 0
        ? currentTasks[indexPath.row]
        : completedTasks[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            StorageManager.shared.delete(task)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        if task.isComplete {
            return UISwipeActionsConfiguration(actions: [deleteAction])
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [unowned self] _, _, isDone in
            showAlert(with: task) {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            isDone(true)
        }
        
        let doneAction = UIContextualAction(style: .normal, title: "Done") { [unowned self] _, _, isDone in
            StorageManager.shared.done(task)
            tableView.moveRow(at: indexPath, to: IndexPath(row: completedTasks.count - 1, section: 1))
            isDone(true)
        }
        
        editAction.backgroundColor = .orange
        doneAction.backgroundColor = .green
        
        return UISwipeActionsConfiguration(actions: [doneAction, editAction, deleteAction])
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc private func addButtonPressed() {
        showAlert()
    }

}

//MARK: Alert controller
extension TasksViewController {
    private func showAlert(with task: Task? = nil, completion: (() -> Void)? = nil) {
        let title = task != nil ? "Edit task" : "New task"
        
        let alert = UIAlertController.createAlertController(withTitle: title, andMessage: "What do you want to do?")
        
        alert.action(with: task) { [weak self] taskTitle, note in
            if let task = task, let completion = completion {
                StorageManager.shared.edit(task, newName: taskTitle, newNote: note)
                completion()
            } else {
                self?.save(task: taskTitle, withNote: note)
            }
        }
        
        present(alert, animated: true)
    }
    
    private func save(task: String, withNote note: String) {
        StorageManager.shared.save(task, withNote: note, to: taskList) { newTask in
            let rowIndex = IndexPath(row: currentTasks.index(of: newTask) ?? 0, section: 0)
            tableView.insertRows(at: [rowIndex], with: .automatic)
        }
    }
}
