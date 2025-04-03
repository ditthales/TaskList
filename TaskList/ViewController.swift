//
//  ViewController.swift
//  TaskList
//
//  Created by ditthales on 03/04/25.
//

import UIKit

class ViewController: UIViewController {
    
    private let coreDataService = CoreDataManager.shared
    
    private var tasks: [TaskItem] = []
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .systemGroupedBackground
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TaskTableViewCell.self, forCellReuseIdentifier: TaskTableViewCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus.circle.fill")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 50)), for: .normal)
        button.tintColor = .systemBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        title = "Minhas Tarefas"
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        setupUI()
        fetchTasks()
    }
    
    private func setupUI() {
        view.addSubview(tableView)
        view.addSubview(addButton)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            addButton.widthAnchor.constraint(equalToConstant: 70),
            addButton.heightAnchor.constraint(equalToConstant: 70)
        ])
    }
    
    private func fetchTasks() {
        tasks = coreDataService.fetchTasks()
        
        tableView.reloadData()
    }
    
    @objc private func addButtonTapped() {
        let alert = UIAlertController(title: "Nova Tarefa", message: "Digite o título da tarefa", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Título da tarefa"
        }
        
        let addAction = UIAlertAction(title: "Adicionar", style: .default) { [weak self] _ in
            guard let title = alert.textFields?.first?.text, !title.isEmpty else { return }
            
            self?.createTask(title: title)
        }
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel)
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func createTask(title: String) {
        if let task = coreDataService.createTask(title: title) {
            tasks.insert(task, at: 0)
            
            tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        } else {
            let alert = UIAlertController(title: "Erro", message: "Não foi possível criar a tarefa. Tente novamente.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
    
    private func toggleTaskCompletion(at indexPath: IndexPath) {
        let task = tasks[indexPath.row]
        
        task.isCompleted.toggle()
        
        do {
            try coreDataService.context.save()
            
            tableView.reloadRows(at: [indexPath], with: .none)
        } catch {
            print("Erro ao atualizar tarefa: \(error)")
        }
    }
}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TaskTableViewCell.identifier, for: indexPath) as? TaskTableViewCell else {
            return UITableViewCell()
        }
        
        let task = tasks[indexPath.row]
        
        cell.delegate = self
        
        cell.configure(with: task)
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let task = tasks[indexPath.row]
            
            coreDataService.deleteTask(task)
            
            tasks.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

// MARK: - TaskTableViewCellDelegate
extension ViewController: TaskTableViewCellDelegate {
    func didTapCheckmark(cell: TaskTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        toggleTaskCompletion(at: indexPath)
    }
}



