# Quiz API App

A Flutter quiz application that fetches real-time questions from the QuizAPI.  
Users can answer multiple-choice questions, receive instant feedback, and view their final score.

---

## Features

- Fetches live quiz questions from a REST API
- Uses async/await for smooth data loading
- Displays multiple-choice questions with randomized answers
- Color-coded feedback:
  - Green = correct
  - Red = incorrect
- Progress tracking with question count and score
- Final results screen with score summary
- "Play Again" functionality to restart the quiz
- Error handling with retry option

---

## Tech Stack

- Flutter (Dart)
- REST API (QuizAPI)
- HTTP package for API calls
- Stateful widgets for UI and state management

---

##  Project Structure


lib/
├── main.dart # App entry point
├── app_config.dart # API key configuration
├── models/
│ └── question.dart # Question data model
├── services/
│ └── trivia_service.dart # API service logic
├── screens/
│ ├── quiz_screen.dart # Quiz UI and logic
│ └── result_screen.dart # Results screen


---

## ⚙️ Getting Started

### 1. Install Flutter
https://docs.flutter.dev/get-started/install

### 2. Get a QuizAPI Key
Sign up and generate an API key:
https://quizapi.io/

### 3. Run the App

``sh
flutter run --dart-define=QUIZ_API_KEY=YOUR_API_KEY_HERE
 Security Note
API keys are not hardcoded in this project.
The app uses environment variables (--dart-define) to securely inject the API key at runtime.
Any previously exposed keys were removed from version history.
OpenAI Integration (Disabled)

This project originally included experimental OpenAI-based features (such as hints and adaptive assistance).
However, these features were disabled and removed from active use to:

Prevent exposing sensitive API keys in a public repository
Comply with GitHub secret scanning and security best practices
Keep the project focused on required assignment functionality
🧠 What This Project Demonstrates
REST API integration in a Flutter app
Asynchronous programming with async / await
Safe data parsing and validation
State management for interactive UI
User-focused design with feedback and progress tracking
🔮 Future Improvements
Re-enable AI-powered hints using secure backend handling
Add categories and difficulty selection
Implement timed quizzes
Add persistent score tracking
Improve UI/UX with animations
📌 Author

Darin Ward

