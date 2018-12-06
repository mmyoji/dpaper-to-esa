# Dropbox Paper to esa

Import data from [Dropbox Paper](https://paper.dropbox.com/) (exported as Markdown) to [esa](https://esa.io/).

## Usage

* Your exported files must be under `docs/` of this project.
* You need following values:
    * `ACCESS_TOKEN`: esa Personal access token (from https://<team_name>.esa.io/user/applications)
    * `TEAM_NAME`: Your esa Team name (subdomain)
    * `DRY_RUN`: For dry run

### Run on Docker

```sh
$ cp .env.example .env
# Edit the Environment variables
$ vi .env

$ docker run -it --rm -v "$PWD":/usr/src/app \
  -w /usr/src/app \
  --env-file=.env \
  ruby:2.5.3-alpine \
  ruby import.rb
```

### Run locally

```sh
# dry run
$ ACCESS_TOKEN=xxx TEAM_NAME=yyy DRY_RUN=1 ruby import.rb

$ ACCESS_TOKEN=xxx TEAM_NAME=yyy ruby import.rb
```

