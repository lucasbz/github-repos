# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'GithubService' do
  let(:stubs)  { Faraday::Adapter::Test::Stubs.new }
  let(:conn)   { Faraday.new { |b| b.adapter(:test, stubs) } }
  let(:service) { GithubService.new(conn) }

  context '#search' do
    it 'returns an empty array when Github returns no repository' do
      stubs.get('https://api.github.com/search/repositories?q=webmock1') do |env|
        expect(env.url.path).to eq('/search/repositories')
        expect(env.params).to eq({ q: 'webmock1' }.with_indifferent_access)
        [200, { 'Content-Type': 'application/javascript' },
         '{"total_count": 0, "incomplete_results": false, "items": []}']
      end

      expect(service.search('webmock1')).to eq({ total_count: 0, incomplete_results: false,
                                                 items: [] }.with_indifferent_access)
      stubs.verify_stubbed_calls
    end

    it 'returns the result body in a map when Github returns a list of repositories' do
      stubs.get('https://api.github.com/search/repositories?q=webmock2') do |env|
        expect(env.url.path).to eq('/search/repositories')
        expect(env.params).to eq({ q: 'webmock2' }.with_indifferent_access)
        [200, { 'Content-Type': 'application/javascript' },
         <<-HEREDOC
            { "total_count": 3, "incomplete_results": false, "items": [
                { "name": "Tetris", "full_name": "dtrupenn/Tetris", "html_url": "https://github.com/dtrupenn/Tetris" },
                { "name": "Tetris 2", "full_name": "dtrupenn/Tetris2", "html_url": "https://github.com/dtrupenn/Tetris2" },
                { "name": "Tetris 3", "full_name": "dtrupenn/Tetris3", "html_url": "https://github.com/dtrupenn/Tetris3" }
              ]
            }
         HEREDOC
        ]
      end

      expect(service.search('webmock2')).to eq({ total_count: 3, incomplete_results: false, items: [
        { name: 'Tetris', full_name: 'dtrupenn/Tetris', html_url: 'https://github.com/dtrupenn/Tetris' },
        { name: 'Tetris 2', full_name: 'dtrupenn/Tetris2', html_url: 'https://github.com/dtrupenn/Tetris2' },
        { name: 'Tetris 3', full_name: 'dtrupenn/Tetris3', html_url: 'https://github.com/dtrupenn/Tetris3' }
      ] }.with_indifferent_access)
      stubs.verify_stubbed_calls
    end
  end

  it 'when Github returns 422' do
    stubs.get('https://api.github.com/search/repositories?q=webmock3') do
      [422, { 'Content-Type': 'application/javascript' }, '{}']
    end
    expect(service.search('webmock3')).to be_empty
    stubs.verify_stubbed_calls
  end

  it 'when Github returns 503' do
    stubs.get('https://api.github.com/search/repositories?q=webmock4') do
      [503, { 'Content-Type': 'application/javascript' }, '{}']
    end
    expect(service.search('webmock4')).to be_empty
    stubs.verify_stubbed_calls
  end

  it 'when there is a connection failure' do
    stubs.get('https://api.github.com/search/repositories?q=webmock5') do
      raise Faraday::ConnectionFailed, nil
    end

    expect { service.search('webmock5') }.to raise_error(Faraday::ConnectionFailed)
    stubs.verify_stubbed_calls
  end
end
