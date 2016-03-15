begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'rdoc/task'
require 'active_record'
require 'rails'

RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Dialectic'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

include ActiveRecord::Tasks

DatabaseTasks.env = Rails.env || 'development'
DatabaseTasks.database_configuration = YAML::load(IO.read('config/database.yml'))
DatabaseTasks.db_dir = 'db'
DatabaseTasks.migrations_paths = 'db/migrate'
DatabaseTasks.root = Rails.root

task :environment do
  ActiveRecord::Base.configurations = DatabaseTasks.database_configuration
  ActiveRecord::Base.establish_connection DatabaseTasks.env.to_sym
end


load 'rails/tasks/statistics.rake'
load 'active_record/railties/databases.rake'


Bundler::GemHelper.install_tasks

