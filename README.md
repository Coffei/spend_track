# SpendTrack

Track your spending with clarity. Understand exactly where your money is going with analytics and automated tracking.

Now running at: https://spendtrack.eu.

## Features

- **Bank Imports**: Seamlessly import transactions from major banks (now only Komerční Banka and Raiffeisen Bank) to keep your records up to date without manual entry.
- **Smart Categorization**: Define fixed deterministic rules once, and watch as new payments are automatically sorted into the right categories instantly upon import.
- **Insightful Analytics**: Gain valuable insights with clean, simple charts that help you visualize spending habits and make informed financial decisions.
- **Secure Access**: Get started instantly with secure Google Login. Your data is protected and accessible only to you.

## AI Disclaimer

AI was used during the development of this project. I used about 80% Cursor and 20% Antigravity with
Gemini 3.

I used AI because I have very limited time and have issues completing projects. I was interested if
AI can help me with that. I also wanted to evaluate different AI services, so it was also a way to
compare/benchmark them.

Since I usually can't dedicate that much time to a project, it is not uncommon that a project dies
before getting to a point where it is usable. Here, with the help of AI, I was able to reach and
sustain much higher pace of development. The ability to skip boring bits, or stuff I didn't feel
like doing at the time helped me to keep focus and interest.

I was able to bring this project into completion (from idea to production, complete in the sense of
the scope I set out to do originally) in about 20 hours.

I call this a win.

## Developer Guide

### Prerequisites

- Elixir (and Erlang)
- PostgreSQL (or Docker)

### Setup

To start your Phoenix server:

1. Run `mix setup` to install and setup dependencies.
2. Ensure you have the necessary environment variables set for Google OAuth:
    - `GOOGLE_CLIENT_ID`
    - `GOOGLE_CLIENT_SECRET`
3. Prepare your Postgresql instance
  1. Either with docker - `docker compose up -d`
  2. Or yourself
    - hostname `localhost`
    - database `spend_track_dev`
    - user `postgres`
    - password `postgres`
    - or customize this in `config/dev.exs`

### Running the Server

Start the Phoenix endpoint with:

```bash
mix phx.server
```

Or inside IEx:

```bash
iex -S mix phx.server
```

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

### Learn more

- Official website: <https://www.phoenixframework.org/>
- Guides: <https://hexdocs.pm/phoenix/overview.html>
- Docs: <https://hexdocs.pm/phoenix>
- Forum: <https://elixirforum.com/c/phoenix-forum>
- Source: <https://github.com/phoenixframework/phoenix>

## Running in production

First create the production environment variables file:

```bash
cp docker-prod/.env.sample docker-prod/.env
```

And fill in the necessary environment variables.

To run the server in production, use:

```bash
cd docker-prod
docker compose build
docker compose up -d
```