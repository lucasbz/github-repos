# frozen_string_literal: true

require 'faraday'
require 'json'

# A GithubService wrapper specific to retrieve public repositories information
class GithubService
  def initialize(conn = nil)
    @conn = conn || Faraday
  end

  def search(search_terms = '')
    return [] if search_terms.empty?

    url = 'https://api.github.com/search/repositories'
    response = @conn.get(url, { q: CGI.escape(search_terms) }) do |req|
      req.headers['Accept'] = 'application/vnd.github.v3+json'
    end
    return [] unless response.status == 200 || response.status == 304

    JSON.parse(response.body)
  end
end
