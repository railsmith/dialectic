require 'rails'

module Dialectic

  class Engine < ::Rails::Engine
    isolate_namespace Dialectic

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_girl, dir: 'spec/factories'
      g.orm :mongoid, migration: true
    end

    initializer "dialectic.orm", after: :load_config_initializers do |app|
       require 'mongoid' if Dialectic.orm == :mongoid
       require 'active_record/railtie' if Dialectic.orm == :active_record
    end
  end
end
