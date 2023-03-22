# frozen_string_literal: true

require 'rest-client'
require 'json'

# An API client for the PlayStation API.
# Based on https://andshrew.github.io/PlayStation-Trophies/#/APIv2
#
class PlaystationApiClient
  AUTH_URL = 'https://ca.account.sony.com/api/authz/v3/oauth'
  TROPHY_URL = 'https://m.np.playstation.com/api/trophy/v1'

  def initialize(npsso)
    access_code = access_code_from_npsso(npsso)
    @access_token = access_token_from_access_code(access_code)
  end

  # NOTE: rest-client requires to pass query params inside the "headers" option when using the GET http method.
  # see https://github.com/rest-client/rest-client#passing-advanced-options

  def my_trophy_titles
    res = RestClient::Request.execute(
      method: :get,
      url: "#{TROPHY_URL}/users/me/trophyTitles",
      headers: {
        params: {
          limit: 800 # the max possible value; I will not handle pagination for now because it is largely enough for me
        },
        Authorization: "Bearer #{@access_token}"
      }
    )
    JSON.parse(res)
  end

  def my_earned_trophies(title_id, service_name)
    res = RestClient::Request.execute(
      method: :get,
      url: "#{TROPHY_URL}/users/me/npCommunicationIds/#{title_id}/trophyGroups/default/trophies",
      headers: {
        params: {
          npServiceName: service_name # `trophy2` for PS5 games, `trophy` for all others
        },
        Authorization: "Bearer #{@access_token}"
      }
    )
    JSON.parse(res)
  end

  private

  def access_code_from_npsso(npsso)
    RestClient::Request.execute(
      method: :get,
      url: "#{AUTH_URL}/authorize",
      headers: {
        params: {
          access_type: 'offline',
          client_id: '09515159-7237-4370-9b40-3806e67c0891',
          response_type: 'code',
          scope: 'psn:mobile.v2.core psn:clientapp',
          redirect_uri: 'com.scee.psxandroid.scecompcall://redirect'
        },
        Cookie: "npsso=#{npsso}"
      },
      max_redirects: 0 # we do not want to be redirected by the 302
    )
  rescue RestClient::Found => e # we catch the redirection to get the access code inside of the response headers
    e.http_headers[:location].match('code=(v3.\w+)')[1]
  end

  def access_token_from_access_code(access_code)
    res = RestClient.post(
      "#{AUTH_URL}/token",
      {
        code: access_code,
        redirect_uri: 'com.scee.psxandroid.scecompcall://redirect',
        grant_type: 'authorization_code',
        token_format: 'jwt'
      },
      {
        content_type: 'application/x-www-form-urlencoded',
        Authorization: 'Basic MDk1MTUxNTktNzIzNy00MzcwLTliNDAtMzgwNmU2N2MwODkxOnVjUGprYTV0bnRCMktxc1A='
      }
    )
    JSON.parse(res)['access_token']
  end
end
