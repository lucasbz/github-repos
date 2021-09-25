# frozen_string_literal: true

# A Github Public Repository
class Repository
  attr_accessor :full_name, :html_url, :description, :forks, :watchers

  def initialize(hash = {})
    hash.each_key do |key|
      m = "#{key}="
      send(m, hash[key]) if respond_to?(m)
    end
  end

  def self.search(search_term = '')
    return [] if search_term.nil? || search_term.empty?
    search_result = GithubService.new.search(search_term)
    search_result['items'].map { |item| Repository.new(item) }
  end
end
