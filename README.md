# Agora Live Broadcasting Feature like Instagram
This is made in flutter framework and with Firebase as backend. The video SDK used is <strong>Agora</strong>

## To run the app

- Clone the repo to your local machine.
- Link your Firebase to the project. Will need Authentication, Cloud FireStore Database and Firebase Storage. Refere [here](https://firebase.google.com/docs/flutter/setup?platform=android) for linking Firebase to Flutter.
- Do note to add the google-service.json file into "android/app/"
- After linking create a Agora account, and create a new project or from existing project get APP ID, and add this to "libs/utils/setting.dart".
- Do not forget to run the below code to get all the required files. 
```
flutter pub get
```

Voila :P run the flutter app by the following code
```
flutter run
```

If anyone wish to add more feature or change exisiting code in more efficient way, do create a pull request.
