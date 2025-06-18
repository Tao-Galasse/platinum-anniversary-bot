# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
require 'active_support'
require 'active_support/time'
require 'discordrb'
require_relative 'playstation_api_client'

# Select every game where I earned the platinum OR achieved 100% completion (because some games do not have a platinum)
def my_completed_games(titles)
  titles.select { |title| title['earnedTrophies']['platinum'] == 1 || title['progress'] == 100 }.map do |title|
    trophies = @playstation_api_client.my_earned_trophies(title['npCommunicationId'], title['npServiceName'])

    platinum = trophies['trophies'].find { |trophy| trophy['trophyType'] == 'platinum' }
    last_trophy = platinum || trophies['trophies'].max_by { it['earnedDateTime'] }
    date = Time.parse(last_trophy['earnedDateTime']).in_time_zone(ENV['TZ'])

    [title['trophyTitleName'], title['trophyTitlePlatform'], title['trophyTitleIconUrl'], date, !platinum.nil?]
  end
end

# Select every game where platinum was earned the same day and month than today, at least 1 year ago
def my_anniversaries(completed_games)
  completed_games.select do |_title, _platform, _icon_url, date, _is_platinum|
    date.strftime('%d/%m') == Date.today.strftime('%d/%m') && date.year != Date.today.year
  end
end

# Send a message on Discord in an embed with all required data on the anniversary
def send_discord_message(title, platform, icon_url, date, is_platinum)
  @discord_bot.send_message(
    ENV['DISCORD_CHANNEL_ID'],
    '',
    false,
    generate_discord_embed(title, platform, icon_url, date, is_platinum)
  )
end

def generate_discord_embed(title, platform, icon_url, date, is_platinum)
  age = Date.today.year - date.year
  years = age == 1 ? 'an' : 'ans'
  trophy_type = is_platinum ? 'platine' : '100%'

  Discordrb::Webhooks::Embed.new(
    title: "Aujourd'hui, nous célébrons l'obtention du #{trophy_type} de #{title} (#{platform}) !",
    description: "Il y a #{age} #{years} :birthday:",
    color: is_platinum ? PS_COLORS[:primary] : PS_COLORS[:secondary],
    thumbnail: Discordrb::Webhooks::EmbedThumbnail.new(url: icon_url)
  )
end

# Official PlayStation colors
PS_COLORS = {
  primary: '#00439C',
  secondary: '#0070D1'
}.freeze

@playstation_api_client = PlaystationApiClient.new(ENV['NPSSO'])

trophy_titles = @playstation_api_client.my_trophy_titles['trophyTitles']
completed_games = my_completed_games(trophy_titles)
anniversaries = my_anniversaries(completed_games)
return if anniversaries.empty?

# If we have at least one anniversary to celebrate, we want to say it on Discord!
@discord_bot = Discordrb::Bot.new(token: ENV['DISCORD_TOKEN'])
anniversaries.each { send_discord_message(*it) }
