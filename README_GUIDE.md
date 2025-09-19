# Big Fan Voice Chat (GitHub-ready)

This repository is prepared to be uploaded to GitHub and connected to Codemagic for Android builds.

## What is included
- `android/` — Android native project files (Gradle configs, manifest, resources)
- `lib/` — Flutter Dart source (`main.dart`)
- `assets/images/logo.png` — App logo
- `pubspec.yaml` — Dependencies and assets including flutter_launcher_icons
- `flutter_launcher_icons.yaml`
- `.gitignore` — Recommended for GitHub
- `README_GENERATED.txt` — Additional notes

## How to upload to GitHub (web UI)
1. Go to https://github.com and create a new repository (e.g. `big_fan_voice_chat`). Do NOT initialize with README or .gitignore (optional).
2. Open the new repo page, click **Add file → Upload files**.
3. Drag & drop the entire contents of this project folder (all files/folders) into the upload area. You can upload entire folders via the web UI.
4. Commit changes (Add a commit message) and finish the upload.

## After upload — Connect to Codemagic
1. Open Codemagic and connect your GitHub account (authorize if necessary).
2. Add a new app in Codemagic and select the repository you just uploaded.
3. Configure the workflow (choose Flutter version and target branch). Ensure the build steps include:
   - `flutter pub get`
   - `flutter pub run flutter_launcher_icons:main`  (optional, to generate icons)
   - `flutter build apk --release`

## If Codemagic complains about Gradle wrapper
- Try adding a pre-build script step in Codemagic:
  - `flutter pub get`
  - `flutter build apk`
  Codemagic will download and use an appropriate Gradle distribution.
- Alternatively, run these commands locally once to generate wrapper files and then push to GitHub:
  - `flutter pub get`
  - `flutter build apk`

## Notes
- If any secret files (keystore) are required, do NOT commit them to GitHub. Use Codemagic secure environment variables and code signing features.
- If you want, I can also prepare a GitHub Actions workflow or provide the exact Codemagic YAML for automation.