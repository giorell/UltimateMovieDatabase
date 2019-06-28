//
//  HomeViewController.swift
//  Capstone_UltimateMDB
//
//  Created by Giordany Orellana on 6/18/19.
//  Copyright © 2019 Giordany Orellana. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var selectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setToolbarHidden(false, animated: true)

        _ = UMDBClient.downloadTrendingMovies() { movies, error in
            if error == nil {
                MovieModel.trendingMovies = movies
                self.collectionView.reloadData()
            } else {
                self.loadError(error!)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            let detailVC = segue.destination as! MovieDetailViewController
            detailVC.movie = MovieModel.trendingMovies[selectedIndex]
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
}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return MovieModel.trendingMovies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "moviePosterCell", for: indexPath) as! MoviesCollectionViewCell
        
        let movie = MovieModel.trendingMovies[indexPath.row]
        
        cell.moviePosterImage.image = UIImage(named: "PosterPlaceholder")
        if let posterPath = movie.posterPath {
            UMDBClient.downloadPosterImage(path: posterPath) { data, error in
                guard let data = data else {
                    return
                }
                let image = UIImage(data: data)?.roundedCorners()
                cell.moviePosterImage?.image = image
            }
        }
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        performSegue(withIdentifier: "showDetail", sender: nil)
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}//END
