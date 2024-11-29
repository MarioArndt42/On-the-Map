//
//  TableViewController.swift
//  On the Map
//
//  Created by Mario Arndt on 01.11.22.
//

import UIKit

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var students = [StudentInformation]()
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func buttonPressed(_ sender: Any) {
        showInfoPostingView(self)
    }
    
    @IBAction func refreshButton(_ sender: Any) {
        reloadData()
    }
    
    @IBAction func buttonLogout(_ sender: Any) {
        ClientUdacity.deleteSession(completion: { result in
            switch result {
            case .success(_):
                self.dismiss(animated: true)
            case .failure(let error):
                self.showAlert(message: error.localizedDescription, title: "Logout Error")
            }
        })
    }
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
        tableView.delegate = self
        tableView.dataSource = self
        reloadData()
    }
    
    // Get list of all students with locations
    func reloadData() {
        ClientUdacity.getLocationList(completion: { result in
            self.activityIndicator.stopAnimating()
            switch result {
            case .success(let students):
                self.students = students
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                self.showAlert(message: error.localizedDescription, title: "Error loading locations")
            }
        })
    }
    
    // Number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }
    
    // Create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let student = students[indexPath.row]
        cell.imageView?.image = UIImage(named: "icon_pin.png")
        cell.textLabel?.text = "\(student.firstName!) \(student.lastName!)"
        cell.detailTextLabel?.text = "\(student.mediaURL!)"
        return cell
    }
    
    // Show student URL in browser
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let student = students[indexPath.row]
        
        let urlString = student.mediaURL ?? ""
        guard let url = URL(string: urlString), UIApplication.shared.canOpenURL(url)
                
        else {
            self.showAlert(message: "Can't open link", title: "Invalid link")
            return
        }
        UIApplication.shared.open(url, options: [:])
    }
    
    // Call InfoPostingView to post location
    func showInfoPostingView(_ sender: Any) {
        let postingController = self.storyboard!.instantiateViewController(withIdentifier: "InfoPostingViewController") as! InfoPostingViewController
        self.present(postingController, animated: true, completion: nil)
        
        // InfoPostingView closed -> Reload table
        postingController.isDismissedTableView = { [weak self] in
            self?.reloadData()
        }
    }
    
}
