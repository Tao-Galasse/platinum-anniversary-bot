# Platinum Anniversary Bot

A bot to retrieve my PlayStation's platinum trophies and celebrate their anniversaries on Discord!

## Usage

### With Github Actions

#### PlayStation API setup

You can fork this repository and add your `NPSSO` variable in the `settings/secrets/actions` section (be careful to never expose your NPSSO publicly).  
If you don't know what your NPSSO is, check the `.env.example` file.

#### Timezone setup

If you want to use a custom timezone, you can define your `TZ` variable in the `settings/variables/actions` section. By default, it will be UTC, as it is the timezone used by Github Actions servers.

#### Discord setup

To send custom messages to celebrate your anniversaries on Discord, you will need to create a bot.

Visit https://discord.com/developers/applications and create a new application.  
Go to the `Bot` section and add your new bot to your Discord server!  
Then, you will need to allow it to `Send Messages` and get your token.  
Add it as a new variable `DISCORD_TOKEN` to your repository in the `settings/secrets/actions` section (this token should never be exposed publicly too).

Finally, add the variable `DISCORD_CHANNEL_ID` in the same section to choose where you want to send your messages.  
To get the ID of a Discord channel, you need to enable the `Developer Mode` in `User Settings > Advanced`.

You can also update the message sent to your Discord channel in the `platinum_anniversary_bot.rb` file (it will require to commit the change).

### Locally

- Install Ruby 3.2.0 (should also work with most of Ruby >= 2.7 versions, but I didn't try them myself. If you want to try another version, update the `.ruby-version` file).
- Add a `.env` file following the format given in `.env.example`.
- Install dependencies with `bundle install` thanks to [bundler](https://bundler.io/). 
- Run `ruby platinum_anniversary_bot.rb`!
