# catsDogs
Authorization case study

Main screen is UITabBarController with 3 tabs
1. Cats images
2. Dogs images
3. Profile

Cats images are available for every user
Dogs images are available for authorized user only
Profile shows username if user is authorized
Profile shows login button if user is not authorized

Login screen will provide credentials input (name/pass text fields) and a button to authorize later

When the user starts the app at the first time, the Login screen appears.
When the user starts the app not at the first time the tab bar screen appears


When the app asks server to authorize with credentials the server replies with a token string.
So requests that require authorization should have an authorization header

If the token is invalid the server will respond with HTTP 401
