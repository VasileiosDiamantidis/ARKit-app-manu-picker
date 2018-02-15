//
//  BacketViewController.swift
//  augmentedRealityPickerFromMenu
//
//  Created by Vasileios Diamantidis on 15/02/2018.
//  Copyright © 2018 vdiamant. All rights reserved.
//

import UIKit

class BacketViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var listPassed:[ListItem]!
    var money:Int!
    @IBOutlet weak var tableItems: UITableView!
    @IBOutlet weak var moneyLabel: UILabel!
    @IBOutlet weak var yourOrderLayer: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableItems.delegate = self
        self.tableItems.dataSource = self
        self.yourOrderLayer.layer.cornerRadius = 10
        self.yourOrderLayer.layer.borderWidth = 2
        self.yourOrderLayer.layer.masksToBounds = true
        //self.yourOrderLayer.layer.borderColor = UIColor.red as! CGColor
        if (money != nil){
            moneyLabel.text = "Total cost \(money!) €"
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listPassed.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:BacketTableViewCell = tableView.dequeueReusableCell(withIdentifier: "BacketTableViewCell", for: indexPath) as! BacketTableViewCell
        
        cell.itemImage.image = self.listPassed[indexPath.row].image
        cell.itemCost.text = "\(self.listPassed[indexPath.row].price!) €"
        cell.itemTitle.text = self.listPassed[indexPath.row].title
        
        return cell
    }

}
