# Notes

## Level 1: what the server really sends

GET /users: status 200, Content-Type: application/json; charset=utf-8,
a JSON list of 10 users.
GET /users/1: status 200, one object (not a list).
GET /users?id=3: status 200, a list with ONE user, not an object.

Top-level keys of a user: id, name, username, email, address, phone, website, company.

Nested objects: address and company. Nested twice: address.geo.

### User
| field    | JSON type | Dart type | nullable? |
|----------|-----------|-----------|-----------|
| id       | number    | int       | no        |
| name     | string    | String    | no        |
| username | string    | String    | no        |
| email    | string    | String    | no        |
| address  | object    | Address   | no        |
| phone    | string    | String    | no        |
| website  | string    | String?   | yes (only field I treat as optional) |
| company  | object    | record ({String name, String catchPhrase}) | no |

### Address
| field   | JSON type | Dart type | nullable? |
|---------|-----------|-----------|-----------|
| street  | string    | String    | no        |
| suite   | string    | String    | no        |
| city    | string    | String    | no        |
| zipcode | string    | String    | no        |
| geo     | object    | Geo       | no        |

### Geo
| field | JSON type | Dart type | nullable? |
|-------|-----------|-----------|-----------|
| lat   | string ("-37.3159") | double (double.parse) | no |
| lng   | string ("81.1496")  | double (double.parse) | no |

### Company
| field       | JSON type | Dart type | nullable? |
|-------------|-----------|-----------|-----------|
| name        | string    | String    | no        |
| catchPhrase | string    | String    | no        |
| bs          | string    | not used in the model | no |

Absent or null: every field is present for all 10 users. I treat only
`website` as optional, because real APIs often leave it out. A missing
`id` or `name` would be a bug in the response.

## Statuses

GET /users/999: status 404 Not Found, body is an empty object `{}`.
POST /users with a JSON body: status 201 Created. The server returns what I
sent plus a new `"id": 11`. It does not really save anything.


## Level 5: two kinds of "no network"
Airplane mode (or Offline in DevTools): the Offline view appeared in about 1 s,
because the OS knows there is no route and SocketException is immediate.
Wi-Fi that leads nowhere (hotspot without internet / unroutable host): the same
Offline view appeared after about 10 s, because packets leave and never return
and only the 10-second timeout stops the wait.

# Practice 12

## Level 1: package verdicts
Order: publisher, last release, platforms, pub points, dependencies, licence.

- shared_preferences: verified publisher flutter.dev, version 2.5.6 released in October 2026,
  all six platforms, 160/160 pub points, a federated plugin that depends on its own
  per-platform packages, BSD-3-Clause.
  Verdict: safe to use, official, fresh and fully scored.
- flutter_secure_storage: verified publisher steenbakker.dev, version 11.2.0 released in
  September 2026, all six platforms, 160/160 pub points, a plugin with per-platform
  implementations, BSD-3-Clause.
  Verdict: safe to use for the token, recent release and a verified publisher, but it is a
  community package, not an official Flutter one.
- path_provider: verified publisher flutter.dev, version 2.1.6 released in June 2026,
  Android, iOS, Linux, macOS and Windows but NOT web, 160/160 pub points, a federated
  plugin, BSD-3-Clause.
  Verdict: safe to use, but the offline file cache works only on mobile and desktop, not in Chrome.
- image_picker: verified publisher flutter.dev, version 1.2.4 released in October 2026,
  all six platforms, 160/160 pub points, a federated plugin, Apache-2.0 and BSD-3-Clause.
  Verdict: safe to use, official and fresh.
- permission_handler: verified publisher baseflow.com, version 13.0.2 released in September
  2026, Android, iOS, web and Windows only (no macOS or Linux), 160/160 pub points, depends
  on its platform interface and per-platform packages, MIT.
  Verdict: safe to use, a well-known community package, and the camera flow is only for mobile anyway.
- url_launcher: verified publisher flutter.dev, version 6.3.3 released in October 2026,
  all six platforms, 160/160 pub points, a federated plugin, BSD-3-Clause.
  Verdict: safe to use, official and fresh.

  
## Level 3: where the token lives
prefs.setString('token', ...) would put the token into a plain, unencrypted file in the
app folder (on Android a shared_prefs XML or a DataStore file, on iOS a plist).
Who can read it: anyone with root or a jailbroken phone, anyone who extracts a backup,
a person with the unlocked phone and a cable, malware with file access. The Keychain (iOS)
and Keystore (Android) keep it encrypted with a key the OS guards.
Two platform surprises: on iOS the Keychain items can survive an app uninstall, so a
reinstalled app may find the old token. On Android the Keystore keys can be wiped when the
screen lock is removed, so the read can fail or return nothing and the app must treat that
as "signed out" (this is why readToken catches PlatformException).