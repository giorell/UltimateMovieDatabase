//
//  MovieDetailViewController.swift
//  Capstone_UltimateMDB
//
//  Created by Giordany Orellana on 6/17/19.
//  Copyright © 2019 Giordany Orellana. All rights reserved.
//

import UIKit
import CoreData

class MovieDetailViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var watchlistBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var favoriteBarButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var popularityCount: UILabel!
    @IBOutlet weak var movieDescription: UITextView!
    
    var movie: Movie!
    var memoryMovie: NSManagedObject?
    
    var isWatchlist: Bool {
        
        if movie == nil && memoryMovie == nil {
            print("both movie and memorymovie are nil")
            return false
        } else if memoryMovie == nil {
            print("memory movie is nil only")
           return MovieModel.watchlistIDs.contains(movie.id)
        }
        print("checking CoreData for movie")
        return self.watchlistExists(id: (memoryMovie?.value(forKey: "id") as? Int ?? 0))
    }

    var isFavorite: Bool {
        if movie == nil && memoryMovie == nil {
            return false
        } else if memoryMovie == nil {
            return MovieModel.favoritesIDs.contains(movie.id)
        }
        return self.favoritesExists(id: (memoryMovie?.value(forKey: "id") as? Int ?? 0))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Watchlist ID: \(MovieModel.watchlistIDs)")
        print("Favorite ID: \(MovieModel.favoritesIDs)")
        print(movie?.id)
        print(memoryMovie)
        
        navigationController?.setToolbarHidden(false, animated: true)
        toggleBarButton(watchlistBarButtonItem, enabled: isWatchlist)
        toggleBarButton(favoriteBarButtonItem, enabled: isFavorite)
        
        if memoryMovie == nil {
            navigationItem.title = movie.title
            if let posterPath = movie.posterPath {
                UMDBClient.downloadPosterImage(path: posterPath) { data, error in
                    self.activityIndicator.startAnimating()
                    guard let data = data else {
                        return
                    }
                    let image = UIImage(data: data)
                    self.imageView.image = image?.roundedCorners()
                    self.activityIndicator.stopAnimating()
                }
            }
            
            if let posterPath = movie.backdropPath {
                UMDBClient.downloadPosterImage(path: posterPath) { data, error in
                    guard let data = data else {
                        return
                    }
                    let image = UIImage(data: data)
                    self.backgroundImage.image = image?.roundedCorners()
                }
            }
            self.popularityCount.text = movie.voteAverage.description
            self.movieDescription.text = movie.overview
        } else {
            navigationItem.title = memoryMovie!.value(forKeyPath: "movieTitle") as? String
            if let posterPath = memoryMovie?.value(forKeyPath: "moviePosterPath") as? String {
                UMDBClient.downloadPosterImage(path: posterPath) { data, error in
                    self.activityIndicator.startAnimating()
                    guard let data = data else {
                        return
                    }
                    let image = UIImage(data: data)
                    self.imageView.image = image?.roundedCorners()
                    self.activityIndicator.stopAnimating()
                }
            }
            
            if let posterPath = memoryMovie?.value(forKeyPath: "movieBackdropPath") as? String {
                UMDBClient.downloadPosterImage(path: posterPath) { data, error in
                    guard let data = data else {
                        return
                    }
                    let image = UIImage(data: data)
                    self.backgroundImage.image = image?.roundedCorners()
                }
            }
            let rating: Double? = memoryMovie?.value(forKeyPath: "movieRating") as? Double
            self.popularityCount.text = rating?.description ?? "0.0"
            self.movieDescription.text = memoryMovie?.value(forKeyPath: "movieDescription") as? String
        }
        
    }
    
    @IBAction func watchlistButtonTapped(_ sender: UIBarButtonItem) {
        self.activityIndicator.startAnimating()
        if memoryMovie == nil {
              UMDBClient.markWatchlist(movieId: movie.id, watchlist: !isWatchlist, completion: handleWatchlistResponse(success:error:))
        } else {
            UMDBClient.markWatchlist(movieId: memoryMovie?.value(forKey: "id") as! Int, watchlist: !isWatchlist, completion: handleWatchlistResponse(success:error:))
        }
        self.activityIndicator.stopAnimating()
    }
    
    @IBAction func favoriteButtonTapped(_ sender: UIBarButtonItem) {
        self.activityIndicator.startAnimating()
        
        if memoryMovie == nil {
            UMDBClient.markFavorite(movieId: movie.id, favorite: !isFavorite, completion: handleFavoriteResponse(success:error:))
        } else {
            UMDBClient.markFavorite(movieId: memoryMovie?.value(forKey: "id") as! Int, favorite: !isFavorite, completion: handleFavoriteResponse(success:error:))
        }
        self.activityIndicator.stopAnimating()
    }
    
    func handleWatchlistResponse(success: Bool, error: Error?) {
        if success {
            if isWatchlist {
                print("before delete: \(MovieModel.watchlistIDs.count)")
                MovieModel.watchlistIDs = MovieModel.watchlistIDs.filter() { $0 != self.memoryMovie?.value(forKey: "id") as! Int }
                self.deleteFromWatchlist(movie: memoryMovie!)
                print("after delete: \(MovieModel.watchlistIDs.count)")
            } else {
                if movie == nil {
                    return
                } else {
                    saveToWatchlist(movie: movie)
                    MovieModel.watchlistIDs.append(movie.id)
                    print("saved to watchlist")
                }
            }
            toggleBarButton(watchlistBarButtonItem, enabled: isWatchlist)
        }
    }

    func handleFavoriteResponse(success: Bool, error: Error?) {
        if success {
            if isFavorite {
                MovieModel.favoritesIDs = MovieModel.favoritesIDs.filter() { $0 != self.memoryMovie?.value(forKey: "id") as! Int }
                self.deleteFromFavorites(movie: memoryMovie!)
            } else {
                if movie == nil {
                    return
                } else {
                    saveToFavorites(movie: movie)
                    MovieModel.favoritesIDs.append(movie.id)
                    print("saved to favorites")
                    print(MovieModel.coreFavoriteMovies.count)
                }
            }
            toggleBarButton(favoriteBarButtonItem, enabled: isFavorite)
        }
    }
    
    func toggleBarButton(_ button: UIBarButtonItem, enabled: Bool) {
        print("Enabled: \(enabled)")
        if enabled {
            button.tintColor = UIColor.orange
        } else {
            button.tintColor = UIColor.gray
        }
    }
    
    func saveToWatchlist(movie: Movie) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
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
        
        MovieModel.watchlistIDs.append(memoryMovie.value(forKey: "id") as! Int)
        //4
        do {
            try managedContext.save()
            MovieModel.coreWatchlistMovies.append(memoryMovie)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func saveToFavorites(movie: Movie) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
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
        
        MovieModel.favoritesIDs.append(memoryMovie.value(forKey: "id") as! Int)
        //4
        do {
            try managedContext.save()
            MovieModel.coreFavoriteMovies.append(memoryMovie)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func deleteFromWatchlist(movie: NSManagedObject){
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        //1
        let managedContext = appDelegate.persistentContainer.viewContext
        
        managedContext.delete(movie)
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
    }
    
    func deleteFromFavorites(movie: NSManagedObject){
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        //1
        let managedContext = appDelegate.persistentContainer.viewContext
        
        managedContext.delete(movie)
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
    }
    
    func watchlistExists(id: Int) -> Bool {
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        //1
        let managedContext = appDelegate?.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "WatchlistMovies")
        
        fetchRequest.predicate = NSPredicate(format: "id = %d", id)
        
        var results: [NSManagedObject] = []
        
        do {
            results = try managedContext!.fetch(fetchRequest)
        }
        catch {
            print("error executing fetch request: \(error)")
        }
        
        return results.count > 0
    }
    
    func favoritesExists(id: Int) -> Bool {
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        //1
        let managedContext = appDelegate?.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "FavoriteMovies")
        
        fetchRequest.predicate = NSPredicate(format: "id = %d", id)
        
        var results: [NSManagedObject] = []
        
        do {
            results = try managedContext!.fetch(fetchRequest)
        }
        catch {
            print("error executing fetch request: \(error)")
        }
        
        return results.count > 0
    }
}
