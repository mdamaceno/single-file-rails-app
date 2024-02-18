require 'bundler/inline'

gemfile(true) do
  source 'https://rubygems.org'

  gem 'rails', '7.1.3'
  gem 'rack', '2.2.8'
  gem 'sqlite3'
  gem 'puma'

  group :development do
    gem 'pry-rails'
  end
end

require 'rails/all'

Rails.logger = Logger.new($stdout)

database = "#{ENV.fetch('RACK_ENV')}.sqlite3"
ENV['DATABASE_URL'] = "sqlite3:#{database}"
ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: database)
ActiveRecord::Base.logger = Logger.new($stdout)

ActiveRecord::Schema.define do
  create_table :users, force: true do |t|
    t.string :name
  end
end

ActiveRecord::Base.connection.execute("INSERT INTO users (name) VALUES ('John Doe')")

class App < Rails::Application
  config.load_defaults 7.1
  config.root = __dir__
  config.consider_all_requests_local = true

  routes.append do
    root to: 'application#index'
  end
end

class User < ActiveRecord::Base
end

class ApplicationController < ActionController::Base
  def index
    render json: { users: User.all }
  end
end

App.initialize!

run App
