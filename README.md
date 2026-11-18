Makersbnb with Reena, Sam, Alex and Ben

![Alt text](img/homepage.png)

```
As a User
So I can list a new space
I want to sign up
```

```
As a User
So I can have someone to hire a space
I want to list a space
```

```
As a User
So I can offer more than one space
I want to list multiple spaces
```

```
As a User
So I can provide a details about my space
I want to be able to add a name, description and price per night.
```

```
As a User
So that I can show availability
I want to show available dates for the spaces
```

```
As a User
So that I can stay for one night
I want to be able to request to hire a space
```

```
As a User
So that I can approve the request to hire
I want to be able to see requests to hire a space
```

```
As a User
So that I can only book available spaces
I want to see available dates
```

```
As a User
So that I can review my booking request
I want my space to remain listed
```

## Security migration (November 2026)

Use Ruby 3.2 or later and the committed Bundler lock. The unsupported DataMapper stack has been replaced by Sequel while preserving the existing `users` and `spaces` table and column names. Configure `DATABASE_URL`, then run `bundle exec rake db:migrate` before starting the app. The migration creates missing tables; it does not drop or alter existing tables. The old destructive `db:auto_migrate` task is removed; `db:auto_upgrade` aliases the safe migration task. Back up and review your existing PostgreSQL schema before deploying this ORM change.

Production requires a `SESSION_SECRET` containing at least 64 random bytes and uses Secure/HttpOnly/SameSite cookies. Listing, selection and request routes require authentication. Mutating forms require a session CSRF token, listing ownership comes from the signed-in user, and all user-controlled template values are escaped. New passwords must contain 8–72 bytes; existing short-password bcrypt hashes remain usable for login.

Run `bundle exec rspec` for the 16 unit/feature/security examples. Tests use an isolated in-memory SQLite database and roll back each example. The suite and the browser sign-in → listing → selection → request-preview flow passed on JRuby 10.1.3.0 (Ruby 4.0.9), with no browser console errors. Gems were checksum-verified and only pure Ruby or precompiled Java archives were installed; native extension scripts were not run. PostgreSQL integration and a production-data migration were not executed.

The demo's request page is a preview. It does not persist or confirm bookings. The previous confirmation wording has been corrected.
