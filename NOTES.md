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