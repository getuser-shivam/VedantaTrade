# CI/CD Service Setup Guide

This guide explains how to configure the necessary GitHub Secrets and external services to activate the automated testing and deployment pipelines for VedantaTrade.

## 🔑 Required GitHub Secrets

To enable building and deploying, add the following secrets to your GitHub repository (**Settings > Secrets and variables > Actions**):

### 📱 Android Release (required for `release.yml`)
1. **`ANDROID_KEYSTORE_BASE64`**: The base64-encoded string of your `keystore.jks` file.
   - Run `[convert]::ToBase64String([IO.File]::ReadAllBytes("keystore.jks"))` in PowerShell to get this string.
2. **`ANDROID_KEYSTORE_PASSWORD`**: The password for your keystore.
3. **`ANDROID_KEY_ALIAS`**: The alias for your signing key (usually the name you gave it).
4. **`ANDROID_KEY_PASSWORD`**: The password for the specific key inside the keystore.

### 🌐 Backend Deployment
1. **`PROD_DATABASE_URL`**: The connection string for your production PostgreSQL database.
2. **`DEPLOY_API_KEY`**: (Platform dependent) API key for AWS, Vercel, or your choice of hosting provider.

### 📢 Notifications
1. **`SLACK_WEBHOOK_URL`**: (Optional) The incoming webhook URL for your Slack channel to receive deployment alerts.

---

## 🛠️ Infrastructure Setup

### 📦 Firebase App Distribution (Recommended for Staging)
1. Go to the [Firebase Console](https://console.firebase.google.com/).
2. Add an Android app and download `google-services.json`.
3. Enable **App Distribution** for the Android app.
4. (In CI) Use the `wzieba/Firebase-Distribution-Github-Action` if you want automated internal testing uploads.

### 🐘 PostgreSQL Database
- Ensure your production database is accessible from GitHub Actions if running migrations.
- **Tip**: Use managed services like Supabase, Railway, or AWS RDS for easier integration.

### 📄 GitHub Pages (Web Staging)
- The pipeline is already configured for GitHub Pages.
- Ensure **Settings > Pages > Build and deployment > Source** is set to "GitHub Actions".

---

## 🚀 Triggering a Release

To create a new production-ready release:
1. Update your version in `pubspec.yaml`.
2. Commit your changes: `git commit -m "Bump version to v1.2.3"`.
3. Create a tag: `git tag v1.2.3`.
4. Push the tag: `git push origin v1.2.3`.

The `release.yml` workflow will automatically build the signed APK/AAB and create a GitHub Release with the artifacts.
