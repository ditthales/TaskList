//
//  CoreDataManager.swift
//  TaskList
//
//  Created by ditthales on 03/04/25.
//

import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    
    private let container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TaskList")
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Erro ao carregar CoreData: \(error)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return container.viewContext
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Erro ao salvar contexto: \(error)")
            }
        }
    }
    
    func createTask(title: String) -> TaskItem? {
        let task = TaskItem(context: context)
        task.title = title
        task.createdAt = Date()
        task.isCompleted = false
        
        // Salva o contexto
        do {
            try context.save()
            return task
        } catch {
            print("Erro ao criar tarefa: \(error)")
            return nil
        }
    }
    
    func fetchTasks() -> [TaskItem] {
        let request: NSFetchRequest<TaskItem> = TaskItem.fetchRequest()
        
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Erro ao buscar tarefas: \(error)")
            return []
        }
    }
    
    func deleteTask(_ task: TaskItem) {
        // Remove a tarefa do contexto
        context.delete(task)
        
        // Salva o contexto
        do {
            try context.save()
        } catch {
            print("Erro ao deletar tarefa: \(error)")
        }
    }
    
}
