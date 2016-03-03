module Dialectic

  mattr_accessor :orm

  class Engine < ::Rails::Engine
    isolate_namespace Dialectic
    
    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_girl, dir: 'spec/factories'
      g.orm Dialectic.orm || :mongoid
    end
  end
end
