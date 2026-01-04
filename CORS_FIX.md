# Fix Firebase Storage CORS Issue

## Problem
Images from Firebase Storage are blocked by CORS policy when accessing from localhost.

## Solution Options

### Option 1: Google Cloud Console (Easiest)
1. Go to: https://console.cloud.google.com/storage
2. Select your bucket: `hk-portfolio1.firebasestorage.app`
3. Click the **3 dots menu** → **Edit bucket permissions** or **CORS configuration**
4. Add this configuration:
```json
[
  {
    "origin": ["*"],
    "method": ["GET"],
    "maxAgeSeconds": 3600
  }
]
```
5. Save

### Option 2: Install Google Cloud SDK
1. Install Google Cloud SDK: https://cloud.google.com/sdk/docs/install
2. Authenticate: `gcloud auth login`
3. Run from this directory:
```bash
gsutil cors set cors.json gs://hk-portfolio1.firebasestorage.app
```

### Option 3: Make Storage URLs Public
1. Go to Firebase Console → Storage
2. Click on the `about` folder
3. Click the **3 dots** on the uploaded image
4. Select **Get download URL** (this creates a public token)
5. The URL should already have a token in it

## Temporary Workaround
Until CORS is fixed, you can test on a deployed site (not localhost) where CORS isn't an issue.

Deploy your site:
```bash
firebase deploy --only hosting
```

Then test at your actual domain instead of localhost.

## Current CORS Configuration File
The `cors.json` file has been created in the project root with the correct configuration.
