# Sports Betting App

## Overview
Sports Betting App is a mobile application built with Swift and UIKit that allows users to browse upcoming sports events, view betting odds from different bookmakers, and create a bet basket. The app displays odds for various sports including soccer, basketball, and more.

## Features
- **Browse Events**: View upcoming sports events with detailed information including teams, dates, and betting odds
- **Multiple Bookmakers**: Access odds from various bookmakers across different regions (US, UK, EU, AU)
- **Bet Basket**: Add selections to your bet basket with automatic calculation of cumulative odds
- **Search and Filter**: Easily find events by team name, sport type, or other criteria
- **Analytics Integration**: Track user interactions with Firebase Analytics

## Technical Architecture
The app follows the MVVM (Model-View-ViewModel) architecture pattern and uses dependency injection for better testability and maintainability.

### Key Components:
- **DataManager**: Handles data fetching and filtering, ensuring only events with valid odds are displayed
- **ServiceManager**: Manages API communication with various regions
- **BetBasket**: Singleton that stores selected bets and calculates total odds
- **EventCell**: Custom table view cell displaying event details with dynamic odds buttons

## Data Flow
1. The app fetches odds data from multiple regions using the Odds API
2. Events without valid odds are filtered out at the data layer
3. Users can browse events and add selections to their bet basket
4. Bet basket updates trigger UI refreshes through a notification system

## Smart Odds Display Logic
- The app intelligently handles odds display, showing only valid odds for each event
- For soccer matches, it displays home, away, and draw odds when available
- For other sports, it shows home and away odds
- All odds are sourced from the same bookmaker for consistency

## Testing
The app includes a comprehensive test suite covering:
- Model validation
- Data filtering
- API communication
- UI interactions

## Requirements
- iOS 14.0+
- Xcode 13.0+
- Swift 5.5+

---

This project was created as a demonstration of iOS development skills, focusing on clean architecture, efficient data handling, and responsive UI design.