require File.join(File.dirname(__FILE__), '..', '..', 'fruit_app')
require 'rack/test'

module AppHelper
  def app
    FruitApp
  end
end

World(Rack::Test::Methods, AppHelper)