//
//  ViewController.swift
//  FirstFireBase
//
//  Created by 김범수 on 2021/07/28.
//

import UIKit
import Firebase

class ViewController: UIViewController {
    
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var numberOfCustomers: UILabel!
    let db = Database.database().reference()
    var customers: [Customer] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        updataLabel()
        //saveBasicTypes()
        fetchCustomers()
        //updateBasicTypes()
        //deleteBasicTypes()
    }
        
    @IBAction func createCustomer(_ sender: Any) {
        saveCustomers()
    }
    
    @IBAction func readCustomer(_ sender: Any) {
        fetchCustomers()
    }
    
    func updateCustomers() {
        guard customers.isEmpty == false else { return }
        customers[0].name = "Min"
        
        let dictionary = customers.map {$0 .toDictionary}
        db.updateChildValues(["customers": dictionary])
    }
    
    @IBAction func updateCustomer(_ sender: Any) {
        updateCustomers()
    }
    
    func deleteCustomers() {
        db.child("customers").removeValue()
    }
    
    @IBAction func removeCustomer(_ sender: Any) {
        deleteCustomers()
    }
}

extension ViewController {
    
    func updataLabel() {
        db.child("firstData").observeSingleEvent(of: .value) { snapshot in
            let value = snapshot.value as? String ?? ""
            DispatchQueue.main.async {
                self.dataLabel.text = value
            }
        }
    }
    
    func saveBasicTypes() {
        db.child("int").setValue(3)
        db.child("double").setValue(3.14)
        db.child("str").setValue("string value : Hi Beomsoo")
        db.child("array").setValue(["a", "b", "c"])
        db.child("dict").setValue(["name": "beomsoo", "age": 25, "city": "Seoul"])
    }
    
    func saveCustomers() {
        let books = [Book(title: "Good to Great", author: "Someone"), Book(title: "Hacking Growth", author: "Somebody")]
        let customer1 = Customer(id: "\(Customer.id)", name: "Son", books: books)
        Customer.id += 1
        let customer2 = Customer(id: "\(Customer.id)", name: "Kim", books: books)
        Customer.id += 1
        let customer3 = Customer(id: "\(Customer.id)", name: "Lee", books: books)
        Customer.id += 1
        
        db.child("customers").child(customer1.id).setValue(customer1.toDictionary)
        db.child("customers").child(customer2.id).setValue(customer2.toDictionary)
        db.child("customers").child(customer3.id).setValue(customer3.toDictionary)
    }
}

extension ViewController {
    func fetchCustomers() {
        db.child("customers").observeSingleEvent(of: .value) { snapshot in
            print("-----> \(snapshot.value)")
            do {
                let data = try JSONSerialization.data(withJSONObject: snapshot.value, options: [])
                let decoder = JSONDecoder()
                let customers: [Customer] = try decoder.decode([Customer].self, from: data)
                self.customers = customers
                DispatchQueue.main.async {
                    self.numberOfCustomers.text = "Number Of Customers : \(customers.count)"
                }
            }
            catch let error{
                print("-----> error: \(error.localizedDescription)")
            }
        }
    }
}

extension ViewController {
    func updateBasicTypes() {
        db.updateChildValues(["int": 6])
        db.updateChildValues(["double": 12.56])
        db.updateChildValues(["str": "Bye Bye"])
    }
    func deleteBasicTypes() {
        db.child("int").removeValue()
        db.child("double").removeValue()
        db.child("str").removeValue()
    }
}

struct Customer: Codable {
    let id: String
    var name: String
    let books: [Book]
    
    var toDictionary: [String: Any] {
        let booksArray = books.map { $0.toDictionary }
        let dict: [String: Any] = ["id": id, "name": name, "books": booksArray]
        return dict
    }
    static var id: Int = 0
}

struct Book: Codable {
    let title: String
    let author: String
    
    var toDictionary: [String: Any] {
        let dict: [String: Any] = ["title": title, "author": author]
        return dict
    }
}
