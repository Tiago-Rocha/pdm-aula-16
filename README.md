# pdm-aula-16 · Local persistence and the login screen

Repository for lesson 16 of PDM (Mobile Device Programming), CTeSP DAW, ESTA, University of the Azores, 2026/27.

Tempo Açores with the islands from the course API (`https://api-pdm.sublimecipher.com`), now with user accounts: each person signs up and logs in inside the app, and the session survives closing the app.

```
lib/
  main.dart                          puts the pieces together
  models/
    island.dart                      Island
    forecast.dart                    WeatherType, DayForecast, Forecast
    user.dart                        AppUser, Session               (step 1)
  data/
    api_client.dart                  HTTP: token, headers, status codes, JSON
    forecast_repository.dart         what the app can ask for (the interface)
    http_forecast_repository.dart    how: asks the API, returns Island
    auth_repository.dart             login, register, refresh, logout (step 1)
    session_store.dart               refresh token in secure storage (step 2)
  state/
    forecast_notifier.dart           loading, error and islands
    session_notifier.dart            who is logged in                (step 1)
    settings.dart                    last email and theme            (step 3)
  screens/
    islands_screen.dart              draws the state, calls load()
    login_screen.dart                log in or create an account     (step 1)
```

## Getting started

```bash
git clone https://github.com/Tiago-Rocha/pdm-aula-16.git
cd pdm-aula-16
flutter pub get
```

Your `clientId` and `clientSecret` are in issue #1 of your `pdm-miniprojeto` repository (or, for the group project, in the issue of your group's repository). They go on the command line, never in the code and never in git:

```bash
flutter run -d chrome --dart-define=CLIENT_ID=pdm-ab12cd --dart-define=CLIENT_SECRET=your-secret
```

The accounts you create belong to the app of those credentials. An account made with your own credentials does not exist in your group's app, and the other way round.

## The steps

There is one branch per step. `main` is the starting point; `passo-3` is the final state.

| Step | Branch | What you do | In the app |
|---|---|---|---|
| 1 | `passo-1` | `AuthRepository` (`POST /v1/auth/login` and `/v1/auth/register`), `SessionNotifier` and `LoginScreen`. `main.dart` shows the login screen while there is no session (`TODO 1`). | A login screen with "Criar conta". After logging in, the islands and "Olá, name" at the top. Logout goes back to the login. |
| 2 | `passo-2` | `SessionStore`: the refresh token in `flutter_secure_storage`. On start, `restore()` asks `POST /v1/auth/refresh` for a new session; logout calls `POST /v1/auth/logout` and deletes the token (`TODO 2`). | Close the app and open it again: you are still logged in. |
| 3 | `passo-3` | `Settings` with `shared_preferences`, loaded before `runApp`: the last email used and the theme (`TODO 3`). | The login screen comes with your email filled in. The theme button stays as you left it. |

To see what a step changed: `git diff main passo-1`, `git diff passo-1 passo-2`, `git diff passo-2 passo-3`.

## Syncing with the lesson

At the end of each step, finished or not, run the commands on the slide, one at a time, in a second terminal. They put aside what you wrote and give you the code of that step:

```bash
git stash -u
git checkout passo-1
flutter pub get
```

Then press `R` in the `flutter run` terminal (hot restart). For step 2, stop the app with `q` and run it again: a hot restart does not show that the session survives.

To go back to the start: `git stash -u` and then `git checkout main`.

## Where things are kept

| What | Where | Why |
|---|---|---|
| Refresh token | `flutter_secure_storage` (Keychain on iOS, Keystore on Android) | It is a password that lasts 30 days. |
| Access token | memory only | It lasts 15 minutes; a new one comes from the refresh token. |
| Last email, theme | `shared_preferences` | Small, not secret, needed on the first frame. |
| Forecasts for offline use | a local database (drift, sqflite) | Lists and JSON that the app searches and replaces. |

On the web, `flutter_secure_storage` encrypts with WebCrypto and keeps the data in the browser; it is not as safe as the Keychain or the Keystore. Test the real thing on a phone or emulator.

API documentation: https://api-pdm.sublimecipher.com/docs

Teacher's content licensed CC BY-NC-SA 4.0.
