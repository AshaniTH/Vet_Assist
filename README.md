# VetAssist – Pet Care Companion App

![VetAssist Logo](assest/images/vetassist_logo.png)

## Overview
**VetAssist** is a mobile application designed to provide seamless pet care management for pet owners. Whether you're managing vet appointments, tracking pet health, or locating emergency vet services, VetAssist brings all essential pet care features into one easy-to-use app.

---

## 🚀 Features

### ✅ Current Features
- **User Authentication**
  - Email/password sign-up and login
  - Google sign-in integration
  - Persistent login sessions

- **App Navigation**
  - Splash screen with animated loading
  - Welcome screen with app introduction
  - Smooth transitions between screens

### 🔄 Planned Features
- Pet profile management  
- Veterinary appointment scheduling  
- Medication reminders  
- Health record tracking  
- Emergency vet location services  

---

## 📸 Screenshots
| Splash Screen | Start Screen | Sign In | Login |
|---------------|--------------|---------|--------|
| ![Splash](assest/images/splash.png) | ![Start](assest/images/start.png) | ![SignIn](assest/images/signin.png) | ![Login](assest/images/login.png) |

---

## 🛠️ Tech Stack

- **Frontend:** Flutter (Dart)  
- **Backend:** Firebase  
  - Firebase Authentication  
  - Firestore (future implementation)  
- **State Management:** Provider *(to be implemented)*  

---

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^2.18.0
  firebase_auth: ^4.11.1
  google_sign_in: ^6.1.5
  flutter_svg: ^2.0.7
