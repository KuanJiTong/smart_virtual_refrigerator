# Flutter App Setup Guide

## 🔐 Environment Configuration

To keep sensitive data like API keys secure and out of version control, this project uses a `.env` file.

### 📄 Step 1: Create a `.env` File

At the **root** directory of the project (same level as `pubspec.yaml`), create a file named:

.env


### ✍️ Step 2: Add the API Key

Inside the `.env` file, add your **Barcode Lookup API key** like this:

BARCODE_LOOKUP_API_KEY=kxegjzl7vm6ks1quwzghanu9mzhb4l


> ⚠️ **Do NOT commit this file to version control.** The `.gitignore` file is already configured to ignore `.env`.

## 🌐 Flask API URL Configuration

Your app communicates with a local Flask server for AI recommendations and retraining. The IP address **must be your actual local network IP**, not `localhost`.

### 🧭 How to Get Your Local IP Address

1. Open Command Prompt (Windows)
2. Run the command:

   ```bash
   ipconfig

### ✏️ Files to Update with Your IP
Make sure to replace all http://192.168.1.10:5000 with your actual local IP.

🔎 recipe_viewmodel.dart (Line 40)

final uri = Uri.parse('http://192.168.1.10:5000/recommend');

🛠️ admin_page.dart (Line 135)

Uri.parse('http://192.168.1.10:5000/retrain');