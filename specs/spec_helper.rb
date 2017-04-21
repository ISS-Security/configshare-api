ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'rack/test'

require './init.rb'

include Rack::Test::Methods

def app
  ShareConfigurationsAPI
end

def invalid_id(resource)
  (resource.max(:id) || 0) + 1
end

def random_str(size)
  chars = [('a'..'z'), ('A'..'Z'), ('0'..'9')].map(&:to_a).flatten
  chars.sample(size).join
end
