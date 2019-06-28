//
//  FavoritesViewController.swift
//  Capstone_UltimateMDB
//
//  Created by Giordany Orellana on 6/17/19.
//  Copyright © 2019 Giordany Orellana. All rights reserved.
//
import UIKit
import CoreData

class FavoritesViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var selectedIndex = 0
    let cellSpacingHeight: CGFloat = 15
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let spinner = UIActivityIndicatorView(style: .gray)
        
        spinner.startAnimating()
        tableView.backgroundView = spinner
        
        loadFavoriteMovies()
        
        if MovieModel.coreFavoriteMovies.isEmpty {
            
            _ = UMDBClient.getFavorites() { movies, error in
                if error == nil {
                    MovieModel.favorites = movies
                    self.save(movies: MovieModel.favorites)
                    self.loadFavoriteMovies()
                    self.tableView.reloadData()
                } else {
                    self.loadError(error!)
                }
            }
        }
        spinner.stopAnimating()
        print("loaded Fav view")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.rowHeight = 150
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            let detailVC = segue.destination as! MovieDetailViewController
            detailVC.memoryMovie = MovieModel.coreFavoriteMovies[selectedIndex]
        }
    }
    
    func loadError(_ error: Error?){
        let alert = UIAlertController(title: "Watchlist Failed To Load", message: "\(String(describing: error))", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: { action in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func loadFavoriteMovies() {
        //1
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "FavoriteMovies")
        
        //3
        do {
            MovieModel.coreFavoriteMovies = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not load. \(error), \(error.userInfo)")
        }
    }
    
    func save(movies: [Movie]) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        for movie in movies {
            
            //1
            let managedContext = appDelegate.persistentContainer.viewContext
            
            //2
            let entity = NSEntityDescription.entity(forEntityName: "FavoriteMovies", in: managedContext)!
            
            let memoryMovie = NSManagedObject(entity: entity, insertInto: managedContext)
            
            //3
            memoryMovie.setValue(movie.title, forKeyPath: "movieTitle")
            memoryMovie.setValue(movie.backdropPath, forKeyPath: "movieBackdropPath")
            memoryMovie.setValue(movie.overview, forKeyPath: "movieDescription")
            memoryMovie.setValue(movie.voteAverage, forKeyPath: "movieRating")
            memoryMovie.setValue(movie.posterPath, forKeyPath: "moviePosterPath")
            memoryMovie.setValue(movie.id, forKeyPath: "id")
            
            print("appending movie ID")
            MovieModel.favoritesIDs.append(movie.id)
            //4
            do {
                try managedContext.save()
                MovieModel.coreFavoriteMovies.append(memoryMovie)
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }
}

extension FavoritesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return MovieModel.coreFavoriteMovies.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieTableViewCell")!
        
        let movie = MovieModel.coreFavoriteMovies[indexPath.section]
                
        cell.textLabel?.text = movie.value(forKeyPath: "movieTitle") as? String
        
        cell.imageView?.image = UIImage(named: "PosterPlaceholder")
        if let posterPath = movie.value(forKeyPath: "moviePosterPath") as? String {
            UMDBClient.downloadPosterImage(path: posterPath) { data, error in
                guard let data = data else {
                    return
                }
                let image = UIImage(data: data)
                cell.imageView?.image = image?.roundedCorners()
                cell.setNeedsLayout()
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.section   
        performSegue(withIdentifier: "showDetail", sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacingHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    @IBAction func logoutButton(_ sender: Any) {
        UMDBClient.logout {
            UserDefaults.standard.set(false, forKey: "status")
            Switcher.updateRootVC()
        }
    }
}
