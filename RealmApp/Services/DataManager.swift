//
//  DataManager.swift
//  RealmApp
//
//  Created by Александр Мамлыго on /87/2566 BE.
//

import Foundation

class DataManager {
    static let shared = DataManager()
    
    private init() {}
    
    func createTempData(completion: @escaping () -> Void) {
        let moviesList = TaskList(
            value: [
                "Movies List",
                Date(),
                [
                    ["Pulp Fiction"],
                    ["Watchmen", "Must have", Date(), true]
                ]
            ]
        )
        
        let shoppingList = TaskList()
        shoppingList.name = "Shopping List"
        
        let milk = Task()
        milk.name = "Milk"
        milk.note = "2L"
        
        let bread = Task(value: ["Bread", "", Date(), true])
        let apples = Task(value: ["name": "Apples", "note": "Erku"])
        
        shoppingList.tasks.insert(contentsOf: [milk, bread, apples], at: 0)
        
        DispatchQueue.main.async {
            StorageManager.shared.save([shoppingList, moviesList])
            completion()
        }
    }
}
