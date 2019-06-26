# UltimateMovieDatabase
Udacity Final Project using themoviedb.org open API database. 

This is my final project for the 2nd semester of the Udacity iOS program. 

The goal of the app for a user is to view the latest trending movies, to add movies to a watchlist or a favorite list, and to view their profile. 

Previews made from iPhone 7. 

The app contains the following view controllers:

1. Login Page
2. Home Page
3. Watchlist Page
4. Search Page
5. Favorites Page
6. Profile Page
7. Movie Detail Page

#### LOGIN PAGE
The login page uses a username and password to access themoviedb.org servers using a reponse token and sessionid. Can be accessed by login in via website as well. 

![image](https://github.com/giorell/UltimateMovieDatabase/blob/master/images/UMDB_loginpage.png)

#### HOME PAGE
The homepage downlaods the latest 20 trending movies. It's a horizontal scrolling UICollectionView so you can scroll from right to left to see the other films. The films can also be clicked to see movie details. The logout button uses a User Defautl setting to save the login status. 

![image](https://github.com/giorell/UltimateMovieDatabase/blob/master/images/UMDB_homepage.png)

#### WATCHLIST PAGE
The watchlist page loads movies a user would like to watch at a future date. Loads the movie poster and the title. 

![image](https://github.com/giorell/UltimateMovieDatabase/blob/master/images/UMDB_watchlist.png)

#### SEARCH PAGE
The search page searches for movies by title name. It loads the movie poster, the title, the release year, and a brief overview. 

![image](https://github.com/giorell/UltimateMovieDatabase/blob/master/images/UMDB_search.png)

#### FAVORITES PAGE
The favorites page loads movies a user's list of favorited movies. 

![image](https://github.com/giorell/UltimateMovieDatabase/blob/master/images/UMDB_favorites.png)

#### PROFILE PAGE
The profile page loads a user's username, profile name, and profile photo. The three items are saved to CoreData and retrieved from CoreData after the profile has been downloaded once. 

![image](https://github.com/giorell/UltimateMovieDatabase/blob/master/images/UMDB_profile.png)

#### MOVIE DETAIL PAGE
The movie detail page contains the poster, raiting, and movie description. The movie can also be saved to the watchlist and favorite's list. It also downloads a background image to liven up the background. 

![image](https://github.com/giorell/UltimateMovieDatabase/blob/master/images/UMDB_moviedetailview.png)

# Requirements

* Xcode 9.2
* Swift 4.0


# License

Copyright (c) Giordany Orellana 2019
