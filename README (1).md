BanjirAid (Flood Emergency Triage & Dispatch)
🛠️ Technical Architecture
The system utilizes a modern cloud-native architecture.


Frontend: Built using Flutter/Web for cross-platform compatibility.


Backend: Firebase handles authentication, real-time database (Firestore), and serverless hosting.


AI Engine: Google Cloud Functions are triggered by new database entries to call the Gemini API for triage and processing.

💻 Implementation Details
The core logic resides within the Firebase Cloud Functions and Firestore data model.


AI Triage: Upon receiving a raw report, Gemini extracts structured data, assigns a priority level (P1-P3), and detects potential duplicates .
+2


Routing: Tickets are auto-routed to responder teams based on AI analysis; abnormal cases are flagged for supervisor review .
+1


Data Model: The system stores Tickets, Locations, Team data, and User roles within Firestore to manage the workflow lifecycle from new requests to resolution .
+1

⚠️ Challenges Faced

Data Scarcity: Managing reports with intermittent mobile data and missing GPS necessitated a reliable landmark-based location fallback system .


Unstructured Input: Reports are often high-volume, messy, incomplete, and multilingual (Malay + English mixed).
+1


Latency: Meeting a median time of less than 10 seconds from report submission to AI triage output requires efficient cloud function execution.

🚀 Future Roadmap

Offline Capability: Implement full offline mesh networking to allow reporting when data networks are completely down.


IoT Integration: Incorporate hardware IoT sensors for automatic flood level monitoring.


Advanced Routing: Develop automated vehicle routing with live traffic optimization for field responders.

⚙️ Project Setup and Launch Guide
Follow these steps to set up the local development environment and launch the application after pulling the repository.

1. Prerequisites
Ensure you have the following installed:

Flutter SDK

Node.js and npm

Firebase CLI

2. Frontend Setup (Flutter)
Navigate to the frontend directory and install dependencies:

Bash
# Navigate to project root
cd banjiraid-app

# Install Flutter dependencies
flutter pub get

# Run the app locally
flutter run
3. Backend Setup (Firebase & Cloud Functions)
Navigate to the functions directory to configure the AI logic:

Bash
# Navigate to functions directory
cd functions

# Install Node.js dependencies
npm install
4. Running the Emulator Suite
To run the full application (Frontend + Firestore + Functions) locally, use the Firebase emulator:

Bash
# From project root
firebase emulators:start
📜 License
Distributed under the Apache License 2.0. See LICENSE for more information.
