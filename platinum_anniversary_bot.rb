# frozen_string_literal: true

require 'active_support/time'
require 'pry' # for testing / debugging purpose
require_relative 'playstation_api_client'

def my_platinum_dates(titles)
  titles.select { |title| title['earnedTrophies']['platinum'] == 1 }.map do |title|
    trophies = @playstation_api_client.my_earned_trophies(title['npCommunicationId'], title['npServiceName'])

    platinum = trophies['trophies'].find { |trophy| trophy['trophyType'] == 'platinum' }
    platinum_earned_date = Time.parse(platinum['earnedDateTime']).in_time_zone(ENV['TZ'])

    [title['trophyTitleName'], platinum_earned_date]
  end
end

@playstation_api_client = PlaystationApiClient.new(ENV['NPSSO'])

trophy_titles = @playstation_api_client.my_trophy_titles['trophyTitles']
platinum_dates = my_platinum_dates(trophy_titles)
puts platinum_dates
