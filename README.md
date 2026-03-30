# Folder

An iOS app for quickly saving and organising content — photos, links, thoughts, and files — to a personal WordPress.com blog. Share anything from any app in seconds using the system Share Extension.

## Features

- **2-column grid feed** with live filters by content type
- **Four content types**
  - **Photos** — pick from your library, uploads media and creates a post
  - **Thoughts** — quick text notes saved as aside posts
  - **Links** — saves URLs with auto-fetched title, description, and favicon preview
  - **Files** — uploads any file (PDF, video, audio, documents, archives)
- **Tile previews on tap**
  - Photos and files open in QuickLook
  - Links open in an in-app SFSafariViewController
  - Thoughts open in a bottom sheet with a Liquid Glass close button
  - Videos play full-screen via AVPlayerViewController with native controls
- **Long press context menu** on every tile
  - Photos, videos, files: Open · Remove
  - Thoughts, links: Open · Edit · Remove
- **Edit in place** — thoughts and links open pre-filled composer sheets; changes reflect instantly without a full feed reload
- **iOS Share Extension** — share URLs, images, and files from any app directly into Folder
- **Pagination** — infinite scroll with 20-post pages
- **Pull to refresh**
- **Account sheet** showing logged-in user and active site

## Tech Stack

| | |
|---|---|
| Language | Swift 5.0 |
| UI | SwiftUI + `@Observable` |
| Min iOS | iOS 26.2 |
| Architecture | MVVM |
| Backend | WordPress.com REST API v1.1 |
| Auth | OAuth 2.0 via `ASWebAuthenticationSession` |
| Storage | Keychain (token) · UserDefaults App Group (shared prefs) |
| Dependencies | None — framework-only |

## Project Structure

```
Folder/
├── Folder/                          # Main app target
│   ├── FolderApp.swift              # @main entry point
│   ├── ContentView.swift            # Root: login → site picker → feed
│   ├── MainGridView.swift           # Feed UI, composers, tile interactions
│   ├── TilePreviewSheet.swift       # Thoughts sheet, video cover
│   ├── SitePickerView.swift         # Site selection after login
│   ├── WordPressAuthManager.swift   # OAuth flow, token exchange, user/site fetch
│   ├── WordPressPostManager.swift   # All API calls (CRUD, media upload)
│   ├── WordPressSite.swift          # Data models: Site, User, Post
│   ├── LinkMetadataFetcher.swift    # Async link preview metadata fetcher
│   └── KeychainHelper.swift        # Token storage + App Group sharing
├── FolderShare/                     # Share Extension target
│   ├── ShareViewController.swift   # Extracts NSExtensionItem attachments
│   └── ShareComposeView.swift      # Composer UI inside the extension
├── FolderTests/
├── FolderUITests/
└── Folder.xcodeproj/
patch_project.py                     # Adds FolderShare target to a fresh project
```

## Getting Started

### Prerequisites

- Xcode 26.2+
- A [WordPress.com](https://developer.wordpress.com/apps/) OAuth app (client ID + secret)

### Setup

1. Clone the repo and open `Folder/Folder.xcodeproj` in Xcode.

2. Create the secrets file (git-ignored):

```swift
// Folder/Folder/WordPressSecrets.swift
enum WordPressSecrets {
    static let clientID     = "<your-client-id>"
    static let clientSecret = "<your-client-secret>"
    static let redirectURI  = "com.bartbak.fastapp.folder://oauth"
}
```

3. Select the **Folder** scheme, choose an iOS 26.2+ simulator or device, and run.

### Share Extension

If adding the extension target to a freshly cloned project:

```bash
python3 patch_project.py
```

## Bundle Identifiers

| Target | Bundle ID |
|---|---|
| Main app | `com.bartbak.fastapp.Folder` |
| Share Extension | `com.bartbak.fastapp.Folder.FolderShare` |
| App Group | `group.com.bartbak.fastapp.folder` |
| Team | `TJ3ALYQV5G` |

## API Overview

All WordPress.com calls live in `WordPressPostManager`. Base URL: `https://public-api.wordpress.com/rest/v1.1`.

| Method | Endpoint | Purpose |
|---|---|---|
| GET | `/sites/{id}/posts` | Fetch paginated feed |
| POST | `/sites/{id}/posts/new` | Create post |
| POST | `/sites/{id}/posts/{id}` | Update post |
| POST | `/sites/{id}/posts/{id}/delete` | Delete post |
| POST | `/sites/{id}/media/new` | Upload media |

## Common Tasks

- **Add a post type** — add creation logic in `WordPressPostManager.swift`, add a compose button in `MainGridView.swift`
- **Change API behavior** — all calls are in `WordPressPostManager.swift`
- **Modify auth** — `WordPressAuthManager.swift`
- **Update share extension UI** — `ShareComposeView.swift`
- **Change data models** — `WordPressSite.swift` (`WordPressPost`, `WordPressSite`, `WordPressUser`)

## Running Tests

```bash
xcodebuild test \
  -project Folder/Folder.xcodeproj \
  -scheme Folder \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

Test coverage is currently minimal.
