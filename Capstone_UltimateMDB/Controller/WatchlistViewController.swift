//
//  WatchlistViewController.swift
//  Capstone_UltimateMDB
//
//  Created by Giordany Orellana on 6/17/19.
//  Copyright © 2019 Giordany Orellana. All rights reserved.
//

import UIKit
import CoreData

class WatchlistViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var selectedIndex = 0
    let cellSpacingHeight: CGFloat = 15
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let spinner = UIActivityIndicatorView(style: .gray)
        
        spinner.startAnimating()
        tableView.backgroundView = spinner
        
        loadWatchlistMovies()
        
        if MovieModel.coreWatchlistMovies.isEmpty {
            
            _ = UMDBClient.getWatchlist() { movies, error in
                if error == nil {
                    MovieModel.watchlist = movies
                    self.save(movies: MovieModel.watchlist)
                    self.loadWatchlistMovies()
                    self.tableView.reloadData()
                } else {
                    self.loadError(error!)
                }
            }
        }
        spinner.stopAnimating()
        print("loaded Watch view")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.rowHeight = 150
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            let detailVC = segue.destination as! MovieDetailViewController
            detailVC.memoryMovie = MovieModel.coreWatchlistMovies[selectedIndex]
        }
    }
    
    @IBAction func logoutButton(_ sender: Any) {
        UMDBClient.logout {
            UserDefaults.standard.set(false, forKey: "status")
            Switcher.updateRootVC()
        }
    }
    
    func loadError(_ error: Error?){
        let alert = UIAlertController(title: "Watchlist Failed To Load", message: "\(String(describing: error))", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: { action in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func loadWatchlistMovies() {
        //1
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "WatchlistMovies")
        
        //3
        do {
            MovieModel.coreWatchlistMovies = try managedContext.fetch(fetchRequest)
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
            let entity = NSEntityDescription.entity(forEntityName: "WatchlistMovies", in: managedContext)!
            
            let memoryMovie = NSManagedObject(entity: entity, insertInto: managedContext)
            
            //3
            memoryMovie.setValue(movie.title, forKeyPath: "movieTitle")
            memoryMovie.setValue(movie.backdropPath, forKeyPath: "movieBackdropPath")
            memoryMovie.setValue(movie.overview, forKeyPath: "movieDescription")
            memoryMovie.setValue(movie.voteAverage, forKeyPath: "movieRating")
            memoryMovie.setValue(movie.posterPath, forKeyPath: "moviePosterPath")
            memoryMovie.setValue(movie.id, forKeyPath: "id")
            
            print("appending movie ID")
            MovieModel.watchlistIDs.append(movie.id)
            //4
            do {
                try managedContext.save()
                MovieModel.coreWatchlistMovies.append(memoryMovie)
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }
    
}



extension WatchlistViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return MovieModel.coreWatchlistMovies.count//MovieModel.watchlist.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieTableViewCell")!
        
        let movie = MovieModel.coreWatchlistMovies[indexPath.section] //MovieModel.watchlist[indexPath.section]
        print(movie)
        
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
    
}
