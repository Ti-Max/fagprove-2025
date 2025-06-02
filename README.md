# Fagprove
This is a Phoenix LiveView Application with PostgreSQL on the Backend.

## Installation
- Nix is used to manage development environment. Follow the instruction on their web site https://nixos.org/download/.
- Install [direnv](https://direnv.net/) to manage environment variables
- Create `.envrc` file. See `.envrc.example`
- Add `cookies.txt` to the root directory (See Yt-dlp section down below)
- Run `direnv allow .` in the root directory. Nix will download Elixir, yt-dlp and other nessasery tool to run the application
- Install [docker](https://www.docker.com/get-started/).
- Run `just up` to start the Postgress database
- In another terminal window run following commands: 
    - Run `mix setup` to install and setup dependencies
    - Run `mix ecto.setup` to setup the database
    - Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`
- Now you can visit [`localhost:4000`](http://localhost:4000) from your browser!

## Yt-dlp
This app uses [yt-dlp](https://github.com/yt-dlp/yt-dlp/tree/master) to download audio files from YouTube. Since YouTube tries blocks automated requests, you may need to export cookies from your local browser. Be carefull not to share them with anyone else. Se this guide on how to do it: https://github.com/yt-dlp/yt-dlp/wiki/FAQ#how-do-i-pass-cookies-to-yt-dlp

## Tests
You can run test with `mix tests` command.

## Deployment
Deployment is done via [Fly.io](https://fly.io/). It uses docker image defined in `Dockerfile`.
To deploy, run the following command: `flyctl deploy --remote-only --build-arg COOKIES_URL=***`
Note: you need to pass a link to a txt file with valid cookies
