# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'RepositoriesController', type: :controller do
  context '#index' do
    subject { get :index }

    it { expect(response).to have_http_status(:ok) }
  end
end
