# MovieApp

## Overview
MovieApp is a Swift-based iOS application that allows users to explore trending movies, manage their watchlist, and view detailed information about each movie. The app utilizes The Movie Database (TMDB) API to fetch movie data.

## Features
- **Trending Movies**: Discover the most trending movies of the week.
-  **Searcg Movie**: Search movie by name.
- **Watchlist Management**: Add or remove movies from your watchlist.
-  **Favorite Management**: Add or remove movies from your favorite.
- **Movie Details**: View detailed information about movies, including genres, ratings, and runtime.

## UI
Link: [Dribbble](https://dribbble.com/shots/22790741-App-for-movies)

## Video Demo
Link: [Video](https://share.cleanshot.com/fCQdZxln)

## Fetures

### Architecture
- The app is built using the MVVM (Model-View-ViewModel) architecture pattern.

### Dependencies
- **URLSession** for network requests.
- **Foundation** and **UIKit** for core functionality.
- **Cosmos** for star rating views.

### API
- The app uses the TMDB API to fetch movie data. You need to obtain an API key from [TMDB](https://www.themoviedb.org/documentation/api) and add it to the `Constants.swift` file.

### Files and Folders
- **Model**: Contains `Movie.swift` and `ListMovies.swift` for movie data modeling.
- **View**: Includes custom views and extensions, such as `ViewExtension.swift`.
- **Controller**: Contains `HomeViewController.swift` for managing the app's main interface.
- **Networking**: `APIManager.swift` handles all network requests to the TMDB API.
- **Utilities**: Includes any helper classes or extensions.

### Setup
1. Clone the repository to your local machine.
2. Open the project in Xcode.
3. Install dependencies by running `pod install` from the terminal in the project directory.
4. Add your TMDB API key to the `Constants.swift` file.
5. Build and run the app on your iOS device or simulator.

## Contribution
Contributions are welcome! Please fork the repository and submit a pull request with your proposed changes or improvements.

## License
This project is licensed under the MIT License - see the LICENSE file for details.
