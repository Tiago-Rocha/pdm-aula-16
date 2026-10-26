# pdm-aula-16 · Local persistence and the login screen

Repository for lesson 16 of PDM (Mobile Device Programming), CTeSP DAW, ESTA, University of the Azores, 2026/27.

Tempo Açores with the islands from the course API (`https://api-pdm.sublimecipher.com`), now with user accounts: each person signs up and logs in inside the app, and the session survives closing the app. This is the code we walk through in the lesson; there are no exercises and no step branches.

```
lib/
  main.dart                          loads the settings, puts the pieces together
  models/
    island.dart                      Island
    forecast.dart                    WeatherType, DayForecast, Forecast
    user.dart                        AppUser, Session
  data/
    api_client.dart                  HTTP: token, headers, status codes, JSON
    forecast_repository.dart         what the app can ask for (the interface)
    http_forecast_repository.dart    how: asks the API, returns Island
    auth_repository.dart             login, register, refresh, logout
    session_store.dart               refresh token in secure storage
  state/
    forecast_notifier.dart           loading, error and islands
    session_notifier.dart            who is logged in
    settings.dart                    last email and theme (shared_preferences)
  screens/
    islands_screen.dart              the islands, the theme button and logout
    login_screen.dart                log in or create an account
```

## Running it

```bash
git clone https://github.com/Tiago-Rocha/pdm-aula-16.git
cd pdm-aula-16
flutter pub get
flutter run -d chrome --dart-define=CLIENT_ID=pdm-ab12cd --dart-define=CLIENT_SECRET=your-secret
```

Your `clientId` and `clientSecret` are in issue #1 of your `pdm-miniprojeto` repository (or, for the group project, in issue #1 of your group's repository). They go on the command line, never in the code and never in git. Pressing F5 in VS Code does not pass them.

The accounts you create belong to the app of those credentials. An account made with your own credentials does not exist in your group's app, and the other way round.

## The login, layer by layer

1. `LoginScreen` validates the form and calls `login(email, password)` on the `SessionNotifier`.
2. `SessionNotifier` sets `isLoading` and asks the `AuthRepository`.
3. `AuthRepository` sends `POST /v1/auth/login` through the `ApiClient` (with the app's `clientId` and `clientSecret`, and the person's email and password).
4. The answer comes back as JSON and becomes a `Session`: the user, a 15-minute access token and a 30-day refresh token.
5. `SessionNotifier` saves the refresh token in the `SessionStore` (`flutter_secure_storage`).
6. Only then does it put the session in its state and call `notifyListeners()`. `main.dart` sees the session and shows the islands instead of the login.

On the next start, `restore()` reads the saved refresh token and asks `POST /v1/auth/refresh` for a new session. Logout deletes the token and calls `POST /v1/auth/logout`.

To see it: log in, stop the app with `q` and run it again. You land on the islands. A hot restart (`R`) does not prove it.

## Where things are kept

| What | Where | Why |
|---|---|---|
| Refresh token | `flutter_secure_storage` (Keychain on iOS, Keystore on Android) | It is a password that lasts 30 days. |
| Access token | memory only | It lasts 15 minutes; a new one comes from the refresh token. |
| Last email, theme | `shared_preferences` | Small, not secret, needed on the first frame. |
| Password | nowhere | The app sends it once and forgets it. |
| Forecasts for offline use | a local database (drift, sqflite) | Lists and JSON that the app searches and replaces. Not in this repository. |

On the web, `flutter_secure_storage` encrypts with WebCrypto and keeps the data in the browser; it is not as safe as the Keychain or the Keystore. Test the real thing on a phone or emulator.

The texts on screen are in Portuguese, like the app in the project; the code and the comments are in English.

API documentation: https://api-pdm.sublimecipher.com/docs

Teacher's content licensed CC BY-NC-SA 4.0.
