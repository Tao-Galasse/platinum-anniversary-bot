# Platinum Anniversary Bot

A bot to retrieve my PlayStation's platinum trophies and celebrate their anniversaries on Discord!

## Usage

### With Github Actions

You can fork this repository and add your `NPSSO` variable in the `settings/secrets/actions` section (be careful to never expose your NPSSO publicly).
If you don't know what your NPSSO is, check the `.env.example` file.

If you want to use a custom timezone, you can define your `TZ` variable in the `settings/variables/actions` section. By default, it will be UTC, as it is the timezone used by Github Actions servers.

_[Document this section with Discord configuration when available]_

### Locally

- Install Ruby 3.2.0 (should also work with most of Ruby >= 2 versions, but I didn't try them myself. If you want to try another version, update the `.ruby-version` file).
- Add a `.env` file following the format given in `.env.example`.
- Install dependencies with `bundle install` thanks to [bundler](https://bundler.io/). 
- Run `ruby platinum_anniversary_bot.rb`!

## TODO

- add a Discord client to post messages on a given room to celebrate an anniversary
- set up a Github Action to run the bot daily