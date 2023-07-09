//
//  Alert Controller + Extensions.swift
//  RealmApp
//
//  Created by Александр Мамлыго on /87/2566 BE.
//

import UIKit

extension UIAlertController {
    static func createAlertController(withTitle title: String, andMessage message: String) -> UIAlertController {
        UIAlertController(title: title, message: message, preferredStyle: .alert)
    }
    
    func action(with taskList: TaskList?, completion: @escaping (String) -> Void) {
        let doneButton = taskList != nil ? "Update" : "Save"
        
        let saveAction = UIAlertAction(title: doneButton, style: .default) { [weak self] _ in
            guard let newValue = self?.textFields?.first?.text else { return }
            guard !newValue.isEmpty else { return }
            completion(newValue)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        addAction(saveAction)
        addAction(cancelAction)
        
        addTextField() { textField in
            textField.placeholder = "List Name"
            textField.text = taskList?.name
        }
    }
    
    func action(with task: Task?, completion: @escaping (String, String) -> Void) {
        let doneButton = task != nil ? "Update" : "Save"
        
        let saveAction = UIAlertAction(title: doneButton, style: .default) { [weak self] _ in
            guard let newTask = self?.textFields?.first?.text else { return }
            guard !newTask.isEmpty else { return }
            
            if let note = self?.textFields?.last?.text, !note.isEmpty {
                completion(newTask, note)
            } else {
                completion(newTask, "")
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        addAction(saveAction)
        addAction(cancelAction)
        
        addTextField() { textField in
            textField.placeholder = "Task Name"
            textField.text = task?.name
        }
        
        addTextField() { textField in
            textField.placeholder = "Note"
            textField.text = task?.note
        }
    }
}
