//
//  ViewController.swift
//  augmentedRealityPickerFromMenu
//
//  Created by Vasileios Diamantidis on 15/02/2018.
//  Copyright © 2018 vdiamant. All rights reserved.
//

import UIKit
import ARKit
import SceneKit

class ViewController: UIViewController, UICollectionViewDelegateFlowLayout{
    
    let activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var itemsCollectionView: UICollectionView!
    @IBOutlet weak var stackViewRotation: UIStackView!
    
    
    @IBOutlet weak var selectedTopLeftImage: UIImageView!
    var listCategories:[UIImage] = [#imageLiteral(resourceName: "Christmas-gifts"),#imageLiteral(resourceName: "candy-crush-png-10"),#imageLiteral(resourceName: "kids"),#imageLiteral(resourceName: "Princess_Throne"),#imageLiteral(resourceName: "toy_car")]
    var listCatString:[String] = ["Presents","Sweets","Kid Games", "Furniture", "Cars"]
    var listPresents:[UIImage] = [#imageLiteral(resourceName: "present"),#imageLiteral(resourceName: "gift (2)")]
    var listCandies:[UIImage] = [#imageLiteral(resourceName: "candy"),#imageLiteral(resourceName: "ice-cream"),#imageLiteral(resourceName: "candy-cane"),#imageLiteral(resourceName: "doughnut"),#imageLiteral(resourceName: "cupcake"),#imageLiteral(resourceName: "ice-cream-1"),#imageLiteral(resourceName: "cupcake (1)")]
    var selectedItem:ListItem!
    var selectedList:[ListItem] = []
    var categoriesforBottomCollectionView:[CategoryItem]!
    var AtLeastOneNodeInserted:Bool = false
    var itemSelected:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.categoriesforBottomCollectionView = self.initializeIndexes()
        self.categoryCollectionView.delegate = self
        self.itemsCollectionView.delegate = self
        self.addTapGestureToSceneView()
        self.addDeligatesToCollectionView()
        self.configureLighting()
        self.stackViewRotation.isHidden = true
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpSceneView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.categoryCollectionView.reloadData()
    }
    func setUpSceneView() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        sceneView.session.run(configuration)
        
        sceneView.delegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }

    func configureLighting() {
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        //return CGSize(width: self.categoryCollectionView.bounds.height, height: self.categoryCollectionView.bounds.height)
//    }
    
    //asd
    
    
    @objc func addNodeToScene(withGestureRecognizer recognizer: UIGestureRecognizer) {
        if(self.itemSelected == true){
            let tapLocation = recognizer.location(in: sceneView)
            let hitTestResults = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
            
            guard let hitTestResult = hitTestResults.first else { return }
            let translation = hitTestResult.worldTransform.translation
            let x = translation.x
            let y = translation.y
            let z = translation.z
            
            var name:String = self.selectedItem.threeDString
            if(name == ""){
                return
            }
            self.startLoading()
            let group = DispatchGroup()
            group.enter()
            DispatchQueue.global(qos: .background).async {
                print("This is run on the background queue")
                
                guard let tempScene = SCNScene(named: name) else{
                    
                    return
                }
                var geom:SCNGeometry = tempScene.rootNode.childNodes[0].geometry!
                //var material:SCNMaterial = SCNMaterial()
                //material.diffuse.contents = #imageLiteral(resourceName: "candy")
                //geom.materials = [material]
                var boxNode:SCNNode = SCNNode(geometry: geom)
                boxNode.scale = SCNVector3(x: 0.2, y:0.2, z:0.2)
                
                
                boxNode.position = SCNVector3(x,(y + 0.2),z)
                self.sceneView.scene.rootNode.addChildNode(boxNode)
                
                for child in self.sceneView.scene.rootNode.childNodes{
                    print("child \(child)")
                    print("______________________________________________________________")
                }
                
                group.leave()
                
            }
            group.notify(queue: .main){
                self.stackViewRotation.isHidden = false
                self.stopLoading()
                self.AtLeastOneNodeInserted = true
            }
        }
    }
    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.addNodeToScene(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @IBAction func rotateRightPressed(_ sender: Any) {
        self.rotateRight()
    }
    
    @IBAction func rotateLeftPressed(_ sender: Any) {
        self.rotateLeft()
    }
    
    
    @IBAction func deleteBtnPressed(_ sender: Any) {
        self.deleteLast()
    }
    
}


extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}

extension UIColor {
    open class var transparentLightBlue: UIColor {
        return UIColor(red: 90/255, green: 200/255, blue: 250/255, alpha: 0.50)
    }
}

extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // 1
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        // 2
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        let plane = SCNPlane(width: width, height: height)
        
        // 3
        plane.materials.first?.diffuse.contents = UIColor.transparentLightBlue
        
        // 4
        let planeNode = SCNNode(geometry: plane)
        
        // 5
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x,y,z)
        planeNode.eulerAngles.x = -.pi / 2
        
        // 6
        node.addChildNode(planeNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // 1
        guard let planeAnchor = anchor as?  ARPlaneAnchor,
            let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else { return }
        
        // 2
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        plane.width = width
        plane.height = height
        
        // 3
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x, y, z)
}
    
    func startLoading(){
        activityIndicator.frame.size = CGSize(width: self.view.frame.size.width / 4, height: self.view.frame.size.width / 4)
        activityIndicator.center = self.view.center;
        activityIndicator.hidesWhenStopped = true;
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge;
        view.addSubview(activityIndicator);
        
        activityIndicator.startAnimating();
        UIApplication.shared.beginIgnoringInteractionEvents();
        
    }
    
    func stopLoading(){
        
        activityIndicator.stopAnimating();
        UIApplication.shared.endIgnoringInteractionEvents();
        
    }
    
    
    
    
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    
    func addDeligatesToCollectionView(){
        self.categoryCollectionView.dataSource = self
        self.itemsCollectionView.dataSource = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(collectionView == self.categoryCollectionView){
            return self.categoriesforBottomCollectionView.count
        }
        
        if(collectionView == self.itemsCollectionView){
            
            return self.selectedList.count
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if(collectionView == self.categoryCollectionView){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCellCollectionViewCell", for: indexPath as IndexPath) as! CategoryCellCollectionViewCell
            // Use the outlet in our custom class to get a reference to the UILabel in the cell
            cell.image.image = self.categoriesforBottomCollectionView[indexPath.row].categoryImage
            //cell.image.image = self.listCategories[indexPath.row]
            //cell.descriptionLabel.text = self.listCatString[indexPath.row]
            cell.descriptionLabel.text = self.categoriesforBottomCollectionView[indexPath.row].categoryTitle
            //cell.backgroundColor = UIColor.cyan // make cell more visible in our example project
            
            return cell
        }
        
        if(collectionView == self.itemsCollectionView){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCollectionViewCell", for: indexPath as IndexPath) as! ItemCollectionViewCell
            // Use the outlet in our custom class to get a reference to the UILabel in the cell
            cell.image.image = self.selectedList[indexPath.row].image
            cell.title.text = self.selectedList[indexPath.row].title
            cell.price.text = "\(self.selectedList[indexPath.row].price!) €"
            //cell.backgroundColor = UIColor.cyan // make cell more visible in our example project
            
            return cell
            
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCellCollectionViewCell", for: indexPath as IndexPath) as! CategoryCellCollectionViewCell
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        cell.image.image = self.selectedList[indexPath.row].image
        //cell.backgroundColor = UIColor.cyan // make cell more visible in our example project
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        if(collectionView == self.itemsCollectionView){
            if(indexPath.row > (self.selectedList.count - 1)){
                return
            }
            self.selectedItem = self.selectedList[indexPath.row]
            self.selectedTopLeftImage.image = self.selectedItem.image
            self.itemSelected = true
        }
        
        if(collectionView == self.categoryCollectionView){
//            if(indexPath.row == 0){
//                self.selectedList = listPresents
//            }else{
//                self.selectedList = listCandies
//            }
            if(indexPath.row > (self.categoriesforBottomCollectionView.count - 1)){
                return
            }
            
            self.selectedList = self.categoriesforBottomCollectionView[indexPath.row].categoryChildList
            self.itemsCollectionView.reloadData()
        }
    }
    
    
    
    
}


extension ViewController {
//    func getSelectedPresentOBJString() -> String {
//        if(self.selectedItem != nil){
//            switch self.selectedItem {
//            case self.listCandies[0]:
//                return "model_586537548780.obj"
//            case self.listCandies[1]:
//                return "model_450388061306.obj"
//            case self.listPresents[0]:
//                return "model_034636223427.obj"
//            case self.listPresents[1]:
//                return "model_274419518493.obj"
//            default:
//                return ""
//            }
//        }
//        return ""
//
//
//    }
    
    
    func rotateRight(){
        if(AtLeastOneNodeInserted){
            let firstAnimation = SCNAction.rotateBy(x: 0, y: 30, z: 0, duration: 0)
            self.sceneView.scene.rootNode.childNodes[self.sceneView.scene.rootNode.childNodes.count - 1].runAction(firstAnimation, completionHandler: nil)
        }
        
    }
    
    func rotateLeft(){
        if(AtLeastOneNodeInserted){
            let firstAnimation = SCNAction.rotateBy(x: 0, y: -30, z: 0, duration: 0)
            self.sceneView.scene.rootNode.childNodes[self.sceneView.scene.rootNode.childNodes.count - 1].runAction(firstAnimation, completionHandler: nil)
        }
    }
    
    func deleteLast(){
        if(AtLeastOneNodeInserted){
            self.sceneView.scene.rootNode.childNodes[self.sceneView.scene.rootNode.childNodes.count - 1].removeFromParentNode()
        }
        self.AtLeastOneNodeInserted = false
        self.stackViewRotation.isHidden = true
    }
    
    
}


extension ViewController{
    
    /*This extension is to add items to view collection
    First you create the items that are ListItem objects
     and then you create a list of them which will be passed
     to the initializer of the CategoryItem object
     In the end you will have a list of CategoryItem objects
     whitch it will be the list for the bottom Collection View
     and every categoryChildList of every Category Item
     is a list for the side Collection view
     
     ! In the future update this will be loaded from server
     */
    func initializeIndexes() -> [CategoryItem]{
        let listCategories:[UIImage] = [#imageLiteral(resourceName: "Christmas-gifts"),#imageLiteral(resourceName: "candy-crush-png-10"),#imageLiteral(resourceName: "kids"),#imageLiteral(resourceName: "Princess_Throne"),#imageLiteral(resourceName: "toy_car")]
        let listCatString:[String] = ["Presents","Sweets","Kid Games", "Furniture", "Cars"]
        let listPresents:[UIImage] = [#imageLiteral(resourceName: "present"),#imageLiteral(resourceName: "gift (2)")]
        let listCandies:[UIImage] = [#imageLiteral(resourceName: "candy"),#imageLiteral(resourceName: "ice-cream"),#imageLiteral(resourceName: "candy-cane"),#imageLiteral(resourceName: "doughnut"),#imageLiteral(resourceName: "cupcake"),#imageLiteral(resourceName: "ice-cream-1"),#imageLiteral(resourceName: "cupcake (1)")]
        let ListItemOne:ListItem = ListItem(name: "red present", image: #imageLiteral(resourceName: "present"), price: 10, ThreeDString: "model_034636223427.obj")
        let ListItemTwo:ListItem = ListItem(name: "greenPresent", image: #imageLiteral(resourceName: "gift (2)"), price: 5, ThreeDString: "model_274419518493.obj")
        let ListItemThree:ListItem = ListItem(name: "candy", image: #imageLiteral(resourceName: "candy"), price: 1, ThreeDString: "model_586537548780.obj")
        let ListItemFour:ListItem = ListItem(name: "ice cream", image: #imageLiteral(resourceName: "ice-cream"), price: 5, ThreeDString: "model_450388061306.obj")
        let ListItemFive:ListItem = ListItem(name: "candy cane", image: #imageLiteral(resourceName: "candy-cane"), price: 1, ThreeDString: "")
        let ListItemSix:ListItem = ListItem(name: "dounaght", image: #imageLiteral(resourceName: "doughnut"), price: 2, ThreeDString: "")
        let ListItemSeven:ListItem = ListItem(name: "cupcake", image: #imageLiteral(resourceName: "cupcake"), price: 4, ThreeDString: "")
        let ListItemEight:ListItem = ListItem(name: "ice cream", image: #imageLiteral(resourceName: "ice-cream-1"), price: 3, ThreeDString: "")
        let ListItemNine:ListItem = ListItem(name: "tart", image: #imageLiteral(resourceName: "cupcake (1)"), price: 1, ThreeDString: "")
        
        
        
        let categoryItemOne:CategoryItem = CategoryItem(categoryName: "Presents", CategoryImage: #imageLiteral(resourceName: "Christmas-gifts"), List: [ListItemOne,ListItemTwo])
        let categoryItemTwo:CategoryItem = CategoryItem(categoryName: "Sweets", CategoryImage: #imageLiteral(resourceName: "candy-crush-png-10"), List: [ListItemThree,ListItemFour, ListItemFive, ListItemSix, ListItemSeven, ListItemEight, ListItemNine])
        let categoryItemThree:CategoryItem = CategoryItem(categoryName: "Kid Games", CategoryImage: #imageLiteral(resourceName: "kids"), List: [])
        let categoryItemFour:CategoryItem = CategoryItem(categoryName: "Furniture", CategoryImage: #imageLiteral(resourceName: "Princess_Throne"), List: [])
        let categoryItemFive:CategoryItem = CategoryItem(categoryName: "Cars", CategoryImage: #imageLiteral(resourceName: "car") , List: [])
        
        let TotalList:[CategoryItem] = [categoryItemOne,categoryItemTwo,categoryItemThree,categoryItemFour,categoryItemFive]
        
        return TotalList
        
    }
    
    
    
    
    
}

