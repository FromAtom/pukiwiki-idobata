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
You do not need to do the following process if you use the `Heroku Button`.

### Redis To Go

```sh
$ heroku addons:add redistogo

```

### Heroku Scheduler

```sh
$ heroku addons:add scheduler:standard
```
## Set job
Add a job `bundle exec ruby pukiwiki-watch-men.rb` on heroku scheduler.
