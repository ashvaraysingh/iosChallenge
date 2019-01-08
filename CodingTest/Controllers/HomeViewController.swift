//
//  HomeViewController.swift
//  CodingTest
//
//  Created by Ashvarya Singh on 08/01/19.
//  Copyright © 2019 Test. All rights reserved.
//

import UIKit
import CoreData

class HomeViewController: UITableViewController {
    
    var planetsArray: [Planet]?
    
    lazy var fetchedhResultController: NSFetchedResultsController<NSFetchRequestResult> = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: PlanetModel.self))
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "nameParam", ascending: true)]
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        frc.delegate = self
        return frc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            try self.fetchedhResultController.performFetch()
            print("COUNT FETCHED FIRST: \(String(describing: self.fetchedhResultController.sections?[0].numberOfObjects))")
        } catch let error  {
            print("ERROR: \(error)")
        }
        self.getAllPlanets()
    }
    
    func getAllPlanets() {
        if let apiURL = URL.init(string: "https://swapi.co/api/planets") {
            URLSession.shared.planetsTask(with: apiURL) { (planets, response, error) in
                if let planetArr = planets?.results, error == nil {
                    self.planetsArray = planetArr
                    DispatchQueue.main.async {
                        self.clearData()
                        self.saveInCoreDataWith(array: planetArr)
                    }
                }
                }.resume()
        }
    }
    
    private func saveInCoreDataWith(array: [Planet]) {
        _ = array.map{self.createPlanetEntityFrom(planet: $0)}
        do {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            try context.save()
        } catch let error {
            print(error)
        }
    }
    
    private func createPlanetEntityFrom(planet: Planet) -> NSManagedObject? {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        if let planetEntity = NSEntityDescription.insertNewObject(forEntityName: "PlanetModel", into: context) as? PlanetModel {
            planetEntity.nameParam = planet.name
            planetEntity.gravityParam = planet.gravity
            return planetEntity
        }
        return nil
    }
    
    private func clearData() {
        do {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: PlanetModel.self))
            do {
                let objects  = try context.fetch(fetchRequest) as? [NSManagedObject]
                _ = objects.map{$0.map{context.delete($0)}}
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.saveContext()
            } catch let error {
                print("ERROR DELETING : \(error)")
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return planetsArray?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlanetCell", for: indexPath)
        if let nameLabel = cell.viewWithTag(11) as? UILabel {
            if let planet = fetchedhResultController.object(at: indexPath) as? PlanetModel {
                nameLabel.text = planet.nameParam
            }
        }
        return cell
    }

}

extension HomeViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            self.tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            self.tableView.deleteRows(at: [indexPath!], with: .automatic)
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
}
