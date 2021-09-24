# frozen_string_literal: true

# Base application class
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
