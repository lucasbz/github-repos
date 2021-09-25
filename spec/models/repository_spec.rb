# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Repository' do
  context '#initialize' do
    context 'missing html_url field' do
      let(:repository) do
        Repository.new({ 'full_name': 'dtrupenn/Tetris',
                         'description': 'desc', 'forks': 10, 'watchers': 10 })
      end
      it { expect(repository.full_name).to eq('dtrupenn/Tetris') }
      it { expect(repository.html_url).to be_nil }
      it { expect(repository.description).to eq('desc') }
      it { expect(repository.forks).to eq(10) }
      it { expect(repository.watchers).to eq(10) }
    end

    context 'hash with all fields' do
      let(:repository) do
        Repository.new({ 'full_name': 'dtrupenn/Tetris', 'html_url': 'https://github.com/dtrupenn/Tetris',
                         'description': 'desc', 'forks': 10, 'watchers': 10,
                         'another_url': 'https://github.com/dtrupenn/Tetris' })
      end
      it { expect(repository.full_name).to eq('dtrupenn/Tetris') }
      it { expect(repository.html_url).to eq('https://github.com/dtrupenn/Tetris') }
      it { expect(repository.description).to eq('desc') }
      it { expect(repository.forks).to eq(10) }
      it { expect(repository.watchers).to eq(10) }
    end
  end

  context '#search' do

    context 'returns an empty array when no search term is provided' do
      let(:repository_search) { Repository.search }
      it { expect(repository_search).to be_empty }
    end

    context 'returns an empty array when search term is an empty string' do
      let(:repository_search) { Repository.search('') }
      it { expect(repository_search).to be_empty }
    end

    context 'returns an array of Repositories when Github returns an array of items' do
      let(:repository_search) { Repository.search("webmock") }
      it {
        mock = double('GithubService')
        allow(GithubService).to receive(:new).and_return(mock)
        allow(mock).to receive(:search).and_return({'items': [
          { 'full_name': 'dtrupenn/Tetris1', 'description': 'desc', 'forks': 10, 'watchers': 10 },
          { 'full_name': 'dtrupenn/Tetris2', 'description': 'desc', 'forks': 10, 'watchers': 10 },
          { 'full_name': 'dtrupenn/Tetris3', 'description': 'desc', 'forks': 10, 'watchers': 10 }
        ]}.with_indifferent_access)
        expect(repository_search).to include(a_kind_of(Repository))
      }
    end

  end
end
