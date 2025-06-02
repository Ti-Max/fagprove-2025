# My Podcasts

My Podcasts is a [Phoenix LiveView](https://github.com/phoenixframework/phoenix_live_view) application backed by a PostgreSQL database. It uses `yt-dlp` for downloading YouTube audio and leverages Nix and Docker for a reproducible development environment.

---

## ⚙️ Installation

### 1. Prerequisites

* **Nix**: Install Nix to manage the development environment. Follow the instructions at [nixos.org/download](https://nixos.org/download/).
* **direnv**: Install [direnv](https://direnv.net/) to manage environment variables.
* **Docker**: Install [Docker](https://www.docker.com/get-started/) to run PostgreSQL.

### 2. Setup Steps

1. Copy `.envrc.example` to `.envrc` and adjust as needed.

2. Add a valid `cookies.txt` file to the root directory (see [Yt-dlp section](#yt-dlp)).

3. In the root directory, run:

   ```sh
   direnv allow .
   ```

   This will trigger Nix to download Elixir, `yt-dlp`, and other necessary tools.

4. Start PostgreSQL with:

   ```sh
   just up
   ```

5. In another terminal window, run:

   ```sh
   mix setup         # installs and sets up dependencies
   mix ecto.setup    # sets up the database
   mix phx.server    # starts the Phoenix server
   ```

6. Visit [http://localhost:4000](http://localhost:4000) in your browser.

---

## Yt-dlp

This app uses [`yt-dlp`](https://github.com/yt-dlp/yt-dlp) to download audio from YouTube. Due to YouTube's restrictions on automated requests, you'll need to export cookies from your browser and save them to a file named `cookies.txt` in the project root.

> ⚠️ **Do not share your cookies file — it contains sensitive session data.**

Follow this guide to export cookies:
[How do I pass cookies to yt-dlp?](https://github.com/yt-dlp/yt-dlp/wiki/FAQ#how-do-i-pass-cookies-to-yt-dlp)

---

## 🧪 Running Tests

To run tests:

```sh
mix test
```

---

## 🚀 Deployment

Deployment is done via [Fly.io](https://fly.io/) using a Docker image defined in the `Dockerfile`.

### To deploy:

```sh
flyctl deploy --remote-only --build-arg COOKIES_URL=***
```

> Replace `***` with the URL to a `cookies.txt` file containing valid YouTube session cookies.

---

