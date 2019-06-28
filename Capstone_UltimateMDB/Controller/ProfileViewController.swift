//
//  ProfileViewController.swift
//  Capstone_UltimateMDB
//
//  Created by Giordany Orellana on 6/18/19.
//  Copyright © 2019 Giordany Orellana. All rights reserved.
//

import UIKit
import CoreData

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    var profile: MDProfile?
    
    var memoryProfile: NSManagedObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadProfile()
        
        if (memoryProfile != nil) {
            
            let name = memoryProfile?.value(forKey: "name") as! String
            
            if name == "" {
                self.nameLabel.text = "Giordany Orellana"
            } else {
                self.nameLabel.text = name
            }
            if let username = memoryProfile?.value(forKey: "username"){
                self.usernameLabel.text = username as? String
            }

            if let avatar = memoryProfile?.value(forKey: "avatarImage"){
                UMDBClient.downloadAvatarImage(path: avatar as! String) { (data, error ) in
                    guard let data = data else {
                        return
                    }
                    let image = UIImage(data: data)
                    self.avatarImageView?.image = image?.roundedImage()
                }
            }
            
        } else {
        print("Fresh load of profile")
        UMDBClient.downloadProfile(completion: { (profile, error) in
            self.profile = profile

            self.usernameLabel.text = profile?.username

            if let avatarPath = profile?.avatar {
                UMDBClient.downloadAvatarImage(path: avatarPath.gravatar.hash) { (data, error ) in
                    guard let data = data else {
                        return
                    }
                    let image = UIImage(data: data)
                    self.avatarImageView?.image = image
                    self.avatarImageView?.layer.cornerRadius = (self.avatarImageView?.frame.size.width)! / 2;
                    self.avatarImageView?.clipsToBounds = true
                }
            }
            self.save(name: self.profile?.name ?? "Unknown Name", avatarImage: self.profile?.avatar.gravatar.hash ?? "Nothing", username: self.profile?.username ?? "Unknown Username")
            
        })
            
        }
    
    }
    
    @IBAction func logoutButton(_ sender: Any) {
        UMDBClient.logout {
            UserDefaults.standard.set(false, forKey: "status")
            Switcher.updateRootVC()
        }
    }
    
    func save(name: String?, avatarImage: String, username: String) {
        print("Saved to Memory")
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Profile", in: managedContext)!
        
        let profile = NSManagedObject(entity: entity, insertInto: managedContext)
        
        profile.setValue(name, forKeyPath: "name")
        profile.setValue(avatarImage, forKey: "avatarImage")
        profile.setValue(username, forKey: "username")
        
        do {
            print("Save successful")
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func loadProfile(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Profile")
        
        fetchRequest.fetchLimit = 1
        do {
            let fetchResults = try managedContext.fetch(fetchRequest)
            self.memoryProfile = fetchResults.last
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}//END
