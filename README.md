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
