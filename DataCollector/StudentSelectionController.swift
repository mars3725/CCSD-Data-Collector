//
//  StudentSelectionController.swift
//  DataCollector
//
//  Created by Matthew Mohandiss on 10/21/16.
//  Copyright © 2016 Matthew Mohandiss. All rights reserved.
//

import UIKit
import CoreData

class StudentSelectionController: UITableViewController {
    var managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var students = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(rightSwipe(_:)))
        rightSwipe.direction = .right
        self.view.addGestureRecognizer(rightSwipe)
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(leftSwipe(_:)))
        leftSwipe.direction = .left
        self.view.addGestureRecognizer(leftSwipe)
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setEditing(false, animated: false)
        students.removeAll()
        do {
            try students.append(contentsOf: managedObjectContext.fetch(NSFetchRequest(entityName: "Student")))
        } catch {
            print("error")
        }
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let seg = segue.destination as? BehaviorInputController {
            seg.student = studentObjectatIndexPath(tableView.indexPathForSelectedRow!)
        }
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }
    
    func rightSwipe(_ gestureRecognizer: UITapGestureRecognizer) {
        setEditing(true, animated: true)
    }
    
    func leftSwipe(_ gestureRecognizer: UITapGestureRecognizer) {
        setEditing(false, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "default", for: indexPath)
        let student = students[indexPath.item]
        let firstName = student.value(forKey: "firstName") as! String
        let lastName = student.value(forKey: "lastName") as! String
        cell.textLabel?.text = firstName + " " + lastName
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
    }
    
    func studentObjectatIndexPath(_ path: IndexPath)-> NSManagedObject? {
        for student in students {
            let firstName = student.value(forKey: "firstName") as! String
            let lastName = student.value(forKey: "lastName") as! String
            if firstName + " " + lastName == tableView.cellForRow(at: path)!.textLabel!.text {
                return student
            }
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            tableView.beginUpdates()
            if let student = studentObjectatIndexPath(indexPath) {
                managedObjectContext.delete(student)
                students.remove(at: students.index(of: student)!)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                tableView.endUpdates()
            }
        }
    }
}
