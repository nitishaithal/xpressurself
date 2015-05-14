require File.expand_path('../boot', __FILE__)

#require 'rails/all'

 require 'rails'
# require 'debugger'
# require 'neo4j-will_paginate'

 %w(
   neo4j
   action_controller
   action_mailer
   sprockets
 ).each do |framework|
   begin
     require "#{framework}/railtie"
   rescue LoadError
   end
 end

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module Ey
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    #config.time_zone = 'New Delhi'

    config.neo4j.session_type = :server_db
    #config.neo4j.session_path = ENV['GRAPHENEDB_URL'] || 'http://localhost:7474'
    config.neo4j.session_path = 'http://app28846332:lMtQ5gb9Om0KgG2IGoYx@app28846332.sb02.stations.graphenedb.com:24789' || 'http://localhost:7474'
    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Example of using UUID instead of Neo4j's id (neo_id)
     config.neo4j.id_property = :uuid
     config.neo4j.id_property_type = :auto
     config.neo4j.id_property_type_value = :uuid

    initializer 'setup_asset_pipeline', :group => :all  do |app|
      # We don't want the default of everything that isn't js or css, because it pulls too many things in
      app.config.assets.precompile.shift

      # Explicitly register the extensions we are interested in compiling
      app.config.assets.precompile.push(Proc.new do |path|
        File.extname(path).in? [
          '.html', '.erb', '.haml',                 # Templates
          '.png',  '.gif', '.jpg', '.jpeg',         # Images
          '.eot',  '.otf', '.svc', '.woff', '.ttf', # Fonts
        ]
      end)
    end

  end
end
