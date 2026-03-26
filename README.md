# BanjirAid (Flood Emergency Triage & Dispatch)

---

## 🛠️ Technical Architecture

The system utilizes a modern cloud-native architecture.
* **Frontend:** Built using Flutter in android to be compatible with common users who use it.
* **Backend:** Firebase handles authentication, real-time database (Firestore), and serverless hosting.
* **AI Engine:** Google Cloud Functions are triggered by new database entries to call the Gemini API for triage and processing.

---

## 💻 Implementation Details
The core logic resides within the Firebase Cloud Functions and Firestore data model.
* **AI Triage:** Upon receiving a raw report, Gemini extracts structured data, assigns a priority level (P1-P3), and detects potential duplicates.
* **Routing:** Tickets are auto-routed to responder teams based on AI analysis; abnormal cases are flagged for supervisor review.
* **Data Model:** The system stores Tickets, Team are stored under @rescue email, and User roles within Firestore to manage the workflow lifecycle from new requests to resolution.

---

## ⚠️ Challenges Faced
* **Data Scarcity:** Managing reports with intermittent mobile data and missing GPS necessitated a reliable landmark-based location fallback system.
* **Unstructured Input:** Reports are often high-volume, messy, incomplete, and multilingual (Malay + English mixed).
* **Latency:** Meeting a median time of less than 10 seconds from report submission to AI triage output requires efficient cloud function execution.

---

## 🚀 Future Roadmap
* **Offline Capability:** Implement full offline mesh networking to allow reporting when data networks are completely down using SMS or basic WIFI as 999 can be fully occupied at the moment.
* **IoT Integration:** Incorporate hardware IoT sensors for automatic flood level monitoring.
* **Advanced Insigts and Execution:** Develop heat seek maps based on the flood API provided by the goverment to monitor water levels and evacuate early or amount of tickets requested in the same area  

---

## ⚙️ Project Setup and Launch Guide

Follow these steps to set up the local development environment and launch the application after pulling the repository.

### 1. Prerequisites
Ensure you have the following installed:
* [Flutter SDK](https://flutter.dev/docs/get-started/install)
* [Node.js and npm](https://nodejs.org/)
* [Firebase CLI](https://firebase.google.com/docs/cli)

### 2. Frontend Setup (Flutter)
Navigate to the frontend directory and install dependencies:
```bash
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
