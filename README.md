# pukiwiki-idobata

# Usage

## Deploy to Heroku
[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy)

## Set options

```sh
$ heroku config:set IDOBATA_HOOK_URL=<idobata-hook-url>
$ heroku config:set PUKIWIKI_RSS_URL=<pukiwiki-rss-url>
```

## Requier Add-Ons

### Redis To Go

```sh
$ heroku addons:add redistogo
$ heroku config:set REDISTOGO_URL=<redistogo-url>
```

### Heroku Scheduler

```sh
$ heroku addons:add scheduler:standard
```

and add a job `bundle exec ruby pukiwiki-watch-men.rb`.
