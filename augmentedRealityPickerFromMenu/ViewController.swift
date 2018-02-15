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
    var selectedItem:UIImage!
    var selectedList:[UIImage] = []
    
    var AtLeastOneNodeInserted:Bool = false
    var itemSelected:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    
    
    
    @objc func addNodeToScene(withGestureRecognizer recognizer: UIGestureRecognizer) {
        if(self.itemSelected == true){
            let tapLocation = recognizer.location(in: sceneView)
            let hitTestResults = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
            
            guard let hitTestResult = hitTestResults.first else { return }
            let translation = hitTestResult.worldTransform.translation
            let x = translation.x
            let y = translation.y
            let z = translation.z
            
            var name:String = self.getSelectedPresentOBJString()
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
            return listCategories.count
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
            cell.image.image = self.listCategories[indexPath.row]
            cell.descriptionLabel.text = self.listCatString[indexPath.row]
            //cell.backgroundColor = UIColor.cyan // make cell more visible in our example project
            
            return cell
        }
        
        if(collectionView == self.itemsCollectionView){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCollectionViewCell", for: indexPath as IndexPath) as! ItemCollectionViewCell
            // Use the outlet in our custom class to get a reference to the UILabel in the cell
            cell.image.image = self.selectedList[indexPath.row]
            //cell.backgroundColor = UIColor.cyan // make cell more visible in our example project
            
            return cell
            
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCellCollectionViewCell", for: indexPath as IndexPath) as! CategoryCellCollectionViewCell
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        cell.image.image = self.selectedList[indexPath.row]
        //cell.backgroundColor = UIColor.cyan // make cell more visible in our example project
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if(indexPath.row > 1){
            return
        }
        if(collectionView == self.itemsCollectionView){
            self.selectedItem = self.selectedList[indexPath.row]
            self.selectedTopLeftImage.image = self.selectedItem
            self.itemSelected = true
        }
        
        if(collectionView == self.categoryCollectionView){
            if(indexPath.row == 0){
                self.selectedList = listPresents
            }else{
                self.selectedList = listCandies
            }
            self.itemsCollectionView.reloadData()
        }
    }
    
    
    
    
}


extension ViewController {
    func getSelectedPresentOBJString() -> String {
        if(self.selectedItem != nil){
            switch self.selectedItem {
            case self.listCandies[0]:
                return "model_586537548780.obj"
            case self.listCandies[1]:
                return "model_450388061306.obj"
            case self.listPresents[0]:
                return "model_034636223427.obj"
            case self.listPresents[1]:
                return "model_274419518493.obj"
            default:
                return ""
            }
        }
        return ""
        
        
    }
    
    
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

