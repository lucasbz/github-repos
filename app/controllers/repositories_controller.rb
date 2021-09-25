# frozen_string_literal: true

# Github Repositories controller
class RepositoriesController < ApplicationController
  def index
    @page = params[:page] || 1
    @q = params['q']
    @search_results = Repository.search @q
  rescue StandardError
    @search_results = []
    flash.now[:error] = 'An error has occurred'
  ensure
    @repositories = Kaminari.paginate_array(@search_results).page(@page).per(10)
  end
end
