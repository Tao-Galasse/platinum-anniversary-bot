# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
require 'active_support'
require 'active_support/time'
require 'discordrb'
require_relative 'playstation_api_client'

# Select every game where I earned the platinum, and return its title, platform, icon_url and earned_date
def my_platinum_dates(titles)
  titles.select { |title| title['earnedTrophies']['platinum'] == 1 }.map do |title|
    trophies = @playstation_api_client.my_earned_trophies(title['npCommunicationId'], title['npServiceName'])

    platinum = trophies['trophies'].find { |trophy| trophy['trophyType'] == 'platinum' }
    platinum_earned_date = Time.parse(platinum['earnedDateTime']).in_time_zone(ENV['TZ'])

    [title['trophyTitleName'], title['trophyTitlePlatform'], title['trophyTitleIconUrl'], platinum_earned_date]
  end
end

# Select every game where platinum was earned the same day and month than today, at least 1 year ago
def my_anniversaries(platinum_dates)
  platinum_dates.select do |_title, _platform, _icon_url, date|
    date.strftime('%d/%m') == Date.today.strftime('%d/%m') && date.year != Date.today.year
  end
end

# Send a message on Discord in an embed with all required data on the anniversary
def send_discord_message(title, platform, icon_url, date)
  age = Date.today.year - date.year
  years = age == 1 ? 'an' : 'ans'

  @discord_bot.send_message(
    ENV['DISCORD_CHANNEL_ID'],
    '',
    false,
    Discordrb::Webhooks::Embed.new(
      title: "Aujourd'hui, nous célébrons l'obtention du platine de #{title} (#{platform}) !",
      description: "Il y a #{age} #{years} :birthday:",
      thumbnail: Discordrb::Webhooks::EmbedThumbnail.new(url: icon_url)
    )
  )
end

@playstation_api_client = PlaystationApiClient.new(ENV['NPSSO'])

trophy_titles = @playstation_api_client.my_trophy_titles['trophyTitles']
platinum_dates = my_platinum_dates(trophy_titles)
anniversaries = my_anniversaries(platinum_dates)
return if anniversaries.empty?

# If we have at least one anniversary to celebrate, we want to say it on Discord!
@discord_bot = Discordrb::Bot.new(token: ENV['DISCORD_TOKEN'])
anniversaries.each { send_discord_message(*it) }
