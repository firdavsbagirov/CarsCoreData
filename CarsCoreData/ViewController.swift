//
//  ViewController.swift
//  CarsCoreData
//
//  Created by Firdavs Bagirov on 10/28/20.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    var context: NSManagedObjectContext!
    var car: Car!
    
    lazy var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .none
        
        return df
    }()
    
    @IBOutlet weak var segmentedControl: UISegmentedControl! {
        didSet{
        
        segmentedControl.backgroundColor = UIColor(red: 232, green: 224, blue: 0, alpha: 1.0)
        updateSegmentedControl()
            
            let whiteTitleTextAttribute = [NSAttributedString.Key.foregroundColor: UIColor.white]
            let blackTitleTextAttribute = [NSAttributedString.Key.foregroundColor: UIColor.black]
            
            UISegmentedControl.appearance().setTitleTextAttributes(whiteTitleTextAttribute, for: .normal)
            UISegmentedControl.appearance().setTitleTextAttributes(blackTitleTextAttribute, for: .selected)
        }
    }
    @IBOutlet weak var markLabel: UILabel!
    @IBOutlet weak var modelLabel: UILabel!
    @IBOutlet weak var carImageView: UIImageView!
    @IBOutlet weak var lastTimeStartedLabel: UILabel!
    @IBOutlet weak var numberOfTripsLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var myChoiseImageView: UIImageView!
    
    @IBAction func segmentedControlPreessed(_ sender: UISegmentedControl) {
        updateSegmentedControl()
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            segmentedControl.backgroundColor = UIColor(red: 232, green: 224, blue: 0, alpha: 1.0)
        case 1:
            segmentedControl.backgroundColor = .systemRed
        case 2:
            segmentedControl.backgroundColor = .blue
        case 3:
            segmentedControl.backgroundColor = .black
        case 4:
            segmentedControl.backgroundColor = UIColor(red: 138, green: 0, blue: 0, alpha: 1.0)
        default:
            break
        }
    }
    
    @IBAction func startEnginePressed(_ sender: UIButton) {
        car.timesDriven += 1
        car.lastStarted = Date()
        
        do {
            try context.save()
            insertDataFrom(selectedCar: car)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
    }
    
    @IBAction func rateButtonPressed(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Rating", message: "Please rate the car", preferredStyle: .alert)
        let rateAction = UIAlertAction(title: "Rate", style: .default) { (action) in
            if let text = alertController.textFields?.first?.text {
                self.update(rating: (text as NSString).doubleValue)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addTextField { (textField) in
            textField.keyboardType = .numberPad
        }
        alertController.addAction(cancelAction)
        alertController.addAction(rateAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func updateSegmentedControl() {
        let fetchRequest: NSFetchRequest<Car> = Car.fetchRequest()
        let mark = segmentedControl.titleForSegment(at: segmentedControl.selectedSegmentIndex)
        fetchRequest.predicate = NSPredicate(format: "mark == %@", mark!)
        
        do {
            let results = try context.fetch(fetchRequest)
            car = results.first
            insertDataFrom(selectedCar: car!)
        } catch let error as NSError {
           print(error.localizedDescription)
        }
    }
    
    private func update(rating: Double) {
        car.rating = rating
        
        do {
            try context.save()
            insertDataFrom(selectedCar: car)
        } catch let error as NSError {
            let alertController = UIAlertController(title: "Wrong value", message: "Wrong input", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default)
            
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
            print(error.localizedDescription)
        }
    }
    
    
    private func insertDataFrom(selectedCar car: Car) {
        carImageView.image = UIImage(data: car.imageData!)
        markLabel.text = car.mark
        modelLabel.text = car.model
        myChoiseImageView.isHidden = !(car.myChoise)
        ratingLabel.text = "Rating: \(car.rating) / 10"
        numberOfTripsLabel.text = "Number of trips: \(car.timesDriven)"
        lastTimeStartedLabel.text = "Last time started: \(dateFormatter.string(from: car.lastStarted!))"
    }
    
    private func getDataFromFile() {
        
        let fetchRequest: NSFetchRequest<Car> = Car.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "mark != 0")
        
        var records = 0
        
        do {
            records = try context.count(for: fetchRequest)
            print("Is Data there already?")
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        guard records == 0 else { return }
        
        //Getting data from file as an array
        guard let pathToFile = Bundle.main.path(forResource: "data", ofType: "plist"),
              let dataArray = NSArray(contentsOfFile: pathToFile) else { return }
        
        for dictionary in dataArray {
            let entity = NSEntityDescription.entity(forEntityName: "Car", in: context)
            let car = NSManagedObject(entity: entity!, insertInto: context) as! Car
            
            let carDictionary = dictionary as! [String: AnyObject]
            car.mark = carDictionary["mark"] as? String
            car.model = carDictionary["model"] as? String
            car.rating = carDictionary["rating"] as! Double
            car.lastStarted = carDictionary["lastStarted"] as? Date
            car.timesDriven = carDictionary["timesDriven"] as! Int16
            car.myChoise = carDictionary["myChoice"] as! Bool
            
            let imageName = carDictionary["imageName"] as? String
            let image = UIImage(named: imageName!)
            let imageData = image?.pngData()
            car.imageData = imageData
            
        }
    }
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getDataFromFile()
        
        let fetchRequest: NSFetchRequest<Car> = Car.fetchRequest()
        let mark = segmentedControl.titleForSegment(at: 0)
        fetchRequest.predicate = NSPredicate(format: "mark == %@", mark!)
        
        do {
            let results = try context.fetch(fetchRequest)
            car = results.first
            insertDataFrom(selectedCar: car!)
        } catch let error as NSError {
           print(error.localizedDescription)
        }
        
        
    }
    
    
}

