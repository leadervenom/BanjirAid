# Project Name: BanjirAid (Flood Emergency Triage & Dispatch)

> [cite_start]A low-bandwidth reporting and dispatch system where citizens submit help requests, and AI acts as the core operator to triage and dispatch automatically. [cite: 9, 14]

## 👥 Team Members
* [cite_start]SAI VAJHRA [cite: 2]
* [cite_start]THEYSIGAN [cite: 3]
* [cite_start]MAHATHEVAN [cite: 4]
* [cite_start]KESAVA [cite: 5]

---

## 🚨 Problem Statement
[cite_start]During floods, help requests arrive in high volume and are often messy, duplicated, incomplete, and unstructured[cite: 11]. [cite_start]Responders lose critical time sorting reports, verifying details, prioritizing, and dispatching manually[cite: 12].

---

## 🚀 Features

### For Victims (Citizen Reporters)
* [cite_start]**Text-First Reporting:** Submit help requests via mobile/web form with optional GPS or landmark-based location entry if data is intermittent[cite: 30, 75, 76].
* [cite_start]**Quick Categories:** Use buttons to select incident types (rescue, medical, supplies) to reduce typing[cite: 169, 170].

### For Responders & Administrators (AI & Human)
* [cite_start]**AI Automated Triage:** Using Google Gemini via API, the system automatically extracts structured information, assigns priority (P1/P2/P3), detects duplicates, and flags suspicious patterns[cite: 15, 16, 17, 18, 19].
* [cite_start]**AI Auto-Assignment:** The AI auto-routes tickets to responder teams under normal conditions[cite: 20].
* [cite_start]**Human-in-the-Loop:** A Facilitator (Supervisor) monitors AI decisions and intervenes only on abnormal cases[cite: 34, 57, 59].
* [cite_start]**Live Dashboard:** Responders view a real-time queue, filter by zone/priority, and update ticket status (en_route, resolved)[cite: 21, 38, 95].
* [cite_start]**Manual Override:** Teams can assign themselves to tickets before the AI does if they are available[cite: 197].

---

## 🛠️ Technical Stack
* [cite_start]**Frontend:** Flutter/Web [cite: 85]
* [cite_start]**Backend:** Firebase (Auth + Firestore) [cite: 85]
* [cite_start]**AI Engine:** Google Cloud Functions calling Gemini API [cite: 15, 85]



---

## ⚙️ Project Setup and Launch Guide

Follow these steps to set up the local development environment and launch the application.

### 1. Prerequisites
Ensure you have the following installed:
* [Flutter SDK](https://flutter.dev/docs/get-started/install)
* [Node.js and npm](https://nodejs.org/)
* [Firebase CLI](https://firebase.google.com/docs/cli)

### 2. Frontend Setup (Flutter)
Navigate to the frontend directory and install dependencies:
```bash
# Navigate to project root
cd relief-router-app

# Install Flutter dependencies
flutter pub get

# Run the app locally
flutter run

# Navigate to functions directory
cd functions

# Install Node.js dependencies
npm install

# From project root
firebase emulators:start

📜 License
Distributed under the MIT License. See LICENSE for more information.
