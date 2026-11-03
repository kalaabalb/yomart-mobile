# Architecture

## Overview

The app is structured as a feature-oriented Flutter client for an e-commerce backend. The architecture centers on Provider for state, a shared HTTP service for API calls, and a model layer for JSON parsing.

## Layers

### Presentation

- Feature screens live under `lib/screen/`
- Shared and reusable UI lives under `lib/shared/widgets/` and `lib/widget/`
- Theme and visual helpers live under `lib/utility/`

### State

- `ChangeNotifier` providers own UI state and remote data loading
- Provider groups cover authentication, catalog browsing, cart, favorites, profile, and ratings

### Data

- `lib/services/http_services.dart` centralizes network requests
- `lib/models/` contains the response models used by the backend
- `GetStorage` is used for lightweight persistent state

## App Flow

1. `main.dart` initializes storage and registers providers.
2. Screens read provider state through `context`.
3. Providers call `HttpService` for backend access.
4. Responses are mapped to model objects.
5. Local state is persisted through `GetStorage` and the cart package.

## Navigation

The repository uses GetX for navigation helpers, dialogs, and snackbar flows.

## Current Folder Conventions

- Feature code stays within the owning feature folder.
- Feature-specific helpers live in `components/` and `provider/`.
- Shared widgets should be added to one canonical shared directory.
- API-facing code should stay out of widget files when possible.
