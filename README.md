# 🎵 Chorded (IOS Album Review App)
Chorded is a music review app, heavily inspired by Letterboxd. It is a fully functional app that allows users to search, rate, and review albums. Users can connect with other users, track activities, and personalize their profiles. This app was written with SwiftUI while authentication and user/album data is handled with Firebase tools. Album information such as tracklist and cover art was obtained via the Discogs API. For any questions or design inquiries, feel free to reach out to the main developer at janice.wong2529@gmail.com.

## 🌟 Features
- Rate & review albums: Users can post one 0-5 (.5 increments) rating and a review for an album. Users are free to modify or delete their review at any time. Their reviews are viewable and their ratings contribute to the community rating for that album.
- Search: Full-text search enables users to quickly navigate to an individual album and artist page.
- Follow users: Users can search for other users via username and view their recent activity and discover new music through their reviews. All activities of a user's following list is viewable in the Activity section of the app.
- Listen list: Users can save an album to their listen list. Albums are automatically removed from the listen list once a review has been written.
- User profile: Each user can easily update their username, bio, and profile picture in the Settings section.
- Home page: Displays the latest trending albums, as well as the top albums of the last 25 years, and the greatest albums of all time for those looking for something to listen to.

## 📱 App Screens
<table>
  <td><img src="https://github.com/user-attachments/assets/06882c50-66d6-48e1-af70-8ac8a444eb48" alt="0D121227-7C9B-4F05-864E-070A909F4526_1_105_c" width="100"/></td>
  <td><img src="https://github.com/user-attachments/assets/783e735f-a156-4abb-8292-c5bc95126e70" alt="CE3EACB8-807C-4BA2-80B3-67A79DC21DA8_1_102_o" width="100"/></td>
  <td><img src="https://github.com/user-attachments/assets/96427a50-4a5e-4a59-ae15-0b3447a8206a" alt="437D275F-A700-490D-AB80-387F49563E8B_1_105_c" width="100"/></td>
  <td><img src="https://github.com/user-attachments/assets/0d24d00b-bf56-4c0e-9a64-3dedc63f2c8f" alt="DE0C7EBE-AEA8-4AE6-ABB0-7838CCE7F1DF_1_105_c" width="100"/></td>
  <td><img src="https://github.com/user-attachments/assets/660dfe01-5b60-4cfe-866c-8805b627e43d" alt="16AF9523-38AA-4AED-A06A-2FBFB359FF1C_1_102_o" width="100"/></td>
</table>

## 🛠️ Technologies Used
- SwiftUI: For building a modern and responsive user interface for IOS 16.0+.
- Firebase: Auth, Storage, and Realtime Database used to authenticate users and store user and album data.

## 🚀 Want To Try it Out?
1. Clone the repository and open in XCode.
2. Go to the [Discogs developer website](https://www.discogs.com/developers) and obtain a consumer key and consumer secret. Insert these credentials in the **SampleDiscogsAPI.plist** file and rename the file to **DiscogsAPI.plist**. You're all set!
