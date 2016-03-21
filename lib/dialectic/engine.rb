require 'rails'
require 'yaml'

module Dialectic

  class Engine < ::Rails::Engine
    isolate_namespace Dialectic

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_girl, dir: 'spec/dummy/spec/factories/'
      g.orm :mongoid, migration: true
    end

    initializer 'dialectic.orm', after: :load_config_initializers do |app|
      begin
        if Dialectic.orm == :mongoid
          require 'mongoid'
          require_relative 'mongoid'
          ENV["RAILS_GROUPS"] = "mongoid"
          Mongoid.load!(Rails.root.join('config', 'mongoid.yml').to_s, Rails.env.to_sym)
        end
        if Dialectic.orm == :active_record
          require 'active_record/railtie'
          require_relative 'active_record'
          ENV["RAILS_GROUPS"] = "active_record"
          ActiveRecord::Base.establish_connection(YAML::load(IO.read(Rails.root.join('config', 'database.yml')))[Rails.env])
        end
      rescue LoadError
        puts 'Dialectic requires either mongoid > 5.0 or activerecord > 4.2.4'
      end
    end
  end
end
