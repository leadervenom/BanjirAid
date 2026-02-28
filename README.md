BanjirAid (Flood Emergency Triage & Dispatch)
A low-bandwidth reporting and dispatch system where citizens submit help requests, and AI acts as the core operator to triage and dispatch automatically.
+1

👥 Team Members
SAI VAJHRA 

THEYSIGAN 

MAHATHEVAN 

KESAVA 

🚨 Problem Statement
During floods, help requests arrive in high volume and are often messy, duplicated, incomplete, and unstructured. Responders lose critical time sorting reports, verifying details, prioritizing, and dispatching manually.
+1

🚀 Features
For Victims (Citizen Reporters)

Text-First Reporting: Submit help requests via mobile/web form with optional GPS or landmark-based location entry if data is intermittent.
+1


Quick Categories: Use buttons to select incident types (rescue, medical, supplies) to reduce typing.

For Responders & Administrators (AI & Human)

AI Automated Triage: Using Google Gemini via API, the system automatically extracts structured information, assigns priority (P1/P2/P3), detects duplicates, and flags suspicious patterns.


AI Auto-Assignment: The AI auto-routes tickets to responder teams under normal conditions.
+1


Human-in-the-Loop: A Facilitator (Supervisor) monitors AI decisions and intervenes only on abnormal cases.
+1


Live Dashboard: Responders view a real-time queue, filter by zone/priority, and update ticket status (en_route, resolved).
+3


Manual Override: Teams can assign themselves to tickets before the AI does if they are available.

🛠️ Technical Stack

Frontend: Flutter/Web 


Backend: Firebase (Auth + Firestore) 


AI Engine: Google Cloud Functions calling Gemini API 

⚙️ Project Setup and Launch Guide
Follow these steps to set up the local development environment and launch the application.

1. Prerequisites
Ensure you have the following installed:

Flutter SDK

Node.js and npm

Firebase CLI

2. Frontend Setup (Flutter)
Navigate to the frontend directory and install dependencies:

Bash
# Navigate to project root
cd relief-router-app

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
Distributed under the MIT License. See LICENSE for more information
