Original App Design Project - README Template
===

# Proxima


## Table of Contents
1. [Overview](#Overview)
1. [Product Spec](#Product-Spec)
1. [Wireframes](#Wireframes)
2. [Schema](#Schema)

## Overview
### Description
Discover nearby attractions, sights, and hidden gems around you. 

### App Evaluation
[Evaluation of your app across the following attributes]
- **Category:** Travel
- **Mobile:** Travelers always have their phone.
- **Story:** The user can find new locations they can visit and tag new locations for other people to see. 
- **Market:** Travelers, wanderlusts, discovering new or familiar places. 
- **Habit:** Useful when looking for a change of scenery, or looking to see something new. Rewards based user interface, gameified.
- **Scope:** Users can tag locations, see locations added by others.

## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**

* Interactive Map
    * Shows locations tagged by other users. Locations can be filtered by type
    * Optional: Have a random button that shows user a random location
* Location Info
    * Shows information, picture(s), description of location
* Add Location
    * User can add location, give it a description, category, photo
* Account Login
    * User can login
* Account Registration
    * User can register a new account


**Optional Nice-to-have Stories**

* User Profile
    * Shows locations created/visited by user, achievements earned
* User Profile Edit
    * User can edit their profile, add photo, 
* Add Location Comment
    * Any user can add comments/pictures to a locationdescription
* Location Feed
    * Show locations in a feed rather than a map (sorted by nearest!)

### 2. Screen Archetypes

* Map
    * Interactive Map
* Login
    * Login / Signup Page
* Register
    * Login / Signup Page
* Detail
    * Location Info
    * User Profile
    * Leaderboard
* Stream
    * Location Feed
* Creation
    * Add Location
    * Add Location Comment
* Settings
    * User Profile Edit

### 3. Navigation

**Tab Navigation** (Tab to Screen)

* Map 
* Feed
* Leaderboard
* Profile

**Flow Navigation** (Screen to Screen)

* Login 
   * Map (home) 
* Register
   * Map (home)
* Map
    * Can take you to detail view of location you click on. 
    * Can take you to create view. 
* Feed
    * Can take you to create view, if you want to add a location. 
    * Detail view of location. 
* Leaderboard
    * Can click on people in leaderboard, and go to their profiles. 
* Creation
    * Can go back to map view, after finalizing creation.
    * Can go back to previous page by canceling. 
* Profile
    * Can go to places posted by that user. 
* Detail 
    * Can go to which user posted that location. 


## Wireframes
<img src="wireframes/home.png" width=600>
<img src="wireframes/map.png" width=600>
<img src="wireframes/feed.png" width=600>
<img src="wireframes/view_location.png" width=600>
<img src="wireframes/add_location.png" width=600>
<img src="wireframes/profile.png" width=600>
<img src="wireframes/leaderboard.png" width=600>

### [BONUS] Interactive Prototype
View on Figma: https://www.figma.com/file/G4TraKzuTCOQRkE9yrGVye/Proxima-Wireframe?node-id=0%3A1
<img src="wireframes/demo.gif" width=600>

## Schema 
Location

| Property | Type | Description |
| -------- | -------- | --------|
| Name     | String     | Name of location     |
| Description  | String     | Description of location 
| Categories   | String[]   | Categories location belongs to     |
| Coordinates  | String     | Geographical coordinates     |
| Pictures     | File[]     |   Holds the pictures associated with this location.   |
| User     | Pointer to PFUser     | The user who submited the story     |
| Comments     | Pointers to Comments     | Comments associated with location     |

Comment
| Property | Type | Description |
| -------- | -------- | --------|
| User     | Pointer to PFUser  | User who made comment  |
| Message  | String     | Content of comment     |
| Time     | TimeDate   | Time comment was made  |


User
| Property | Type | Description |
| -------- | -------- | --------|
| User     | Pointer to PFUser     | User      |
| Name     | String   | Content of comment     |
| Profile picture     | File[]     | Picture     |
| Created Locations   | Pointer to Locations     | Locations user created     |
| Visited Locations   | Pointer to Locations     | Locations user visited     |
| Score     | Number  | Points earned by user |
| Achievements     | Pointer to Achievements  | Achievements awarded to user |



**Login / Register**
(Read/GET) Get user
(Create/POST) Create new users

**Map**
- (Read/GET) Get Locations

**Feed**
- (Read/GET) Get Locations

**Add Location**
- (Create/POST) Create new Locations

**View Location**
- (Read/GET) Get locations
- (Delete) Delete a Comment belonging to location

**Add Comment**
- (Create/POST) Create new Comment

**Leaderboard**
- (Read/GET) Get all Users

**Profile**
- (Read/GET) Get User
- (Update/PUT) Update User information
### Models
[Add table of models]
### Networking
- [Add list of network requests by screen ]
- [Create basic snippets for each Parse network request]
- [OPTIONAL: List endpoints if using existing API such as Yelp]
### Sprint 1 Demo
<img src="deni/demo_1.gif" width=600>
