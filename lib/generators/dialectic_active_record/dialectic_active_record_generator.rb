module ActiveRecord
  module Generators # :nodoc:
    module Migration
      extend ActiveSupport::Concern
      include Rails::Generators::Migration

      module ClassMethods
        # Implement the required interface for Rails::Generators::Migration.
        def next_migration_number(dirname)
          next_migration_number = current_migration_number(dirname) + 1
          ActiveRecord::Migration.next_migration_number(next_migration_number)
        end
      end

      private

      def primary_key_type
        key_type = options[:primary_key_type]
        ", id: :#{key_type}" if key_type
      end
    end
  end
end

class DialecticActiveRecordGenerator < Rails::Generators::NamedBase
  include ActiveRecord::Generators::Migration

  ActiveRecord::Base.configurations = YAML::load(IO.read('config/database.yml'))
  ActiveRecord::Base.establish_connection Rails.env.to_sym

  source_root File.expand_path('../templates', __FILE__)

  argument :attributes, :type => :array, :default => [], :banner => "field[:type][:index] field[:type][:index]"

  check_class_collision

  class_option :migration, type: :boolean
  class_option :timestamps, type: :boolean
  class_option :parent, type: :string, desc: "The parent class for the generated model"
  class_option :indexes, type: :boolean, default: true, desc: "Add indexes for references and belongs_to columns"
  class_option :primary_key_type, type: :string, desc: "The type for primary key"

  # creates the migration file for the model.
  def create_migration_file
    return unless options[:migration] && options[:parent].nil?
    attributes.each { |a| a.attr_options.delete(:index) if a.reference? && !a.has_index? } if options[:indexes] == false
    migration_template "create_table_migration.rb", "db/migrate/create_#{table_name}.rb"
  end

  def create_model_file
    template 'model.rb', File.join('lib', class_path, 'active_record/' "#{file_name}.rb")
    generate_application_record
  end

  def create_module_file
    return if regular_class_path.empty?
    template 'module.rb', File.join('lib', "#{class_path.join('/')}.rb") if behavior == :invoke
    generate_application_record
  end

  hook_for :test_framework

  protected

  def attributes_with_index
    attributes.select { |a| !a.reference? && a.has_index? }
  end

  # FIXME: Change this file to a symlink once RubyGems 2.5.0 is required.
  def generate_application_record
    if self.behavior == :invoke && !application_record_exist?
      template 'application_record.rb', application_record_file_name
    end
  end

  # Used by the migration template to determine the parent name of the model
  def parent_class_name
    options[:parent] || determine_default_parent_class
  end

  def application_record_exist?
    file_exist = nil
    in_root { file_exist = File.exist?(application_record_file_name) }
    file_exist
  end

  def application_record_file_name
    @application_record_file_name ||= if mountable_engine?
                                        "lib/#{namespaced_path}/active_record/application_record.rb"
                                      else
                                        'lib/active_record/application_record.rb'
                                      end
  end

  def determine_default_parent_class
    if application_record_exist?
      "ApplicationRecord"
    else
      "ActiveRecord::Base"
    end
  end
end


require 'active_support/time'

module Rails
  module Generators
    class GeneratedAttribute # :nodoc:
      INDEX_OPTIONS ||= %w(index uniq)
      UNIQ_INDEX_OPTIONS ||= %w(uniq)

      attr_accessor :name, :type
      attr_reader   :attr_options
      attr_writer   :index_name

      class << self
        def parse(column_definition)
          name, type, has_index = column_definition.split(':')

          # if user provided "name:index" instead of "name:string:index"
          # type should be set blank so GeneratedAttribute's constructor
          # could set it to :string
          has_index, type = type, nil if INDEX_OPTIONS.include?(type)

          type, attr_options = *parse_type_and_options(type)
          type = type.to_sym if type

          if type && reference?(type)
            if UNIQ_INDEX_OPTIONS.include?(has_index)
              attr_options[:index] = { unique: true }
            end
          end

          new(name, type, has_index, attr_options)
        end

        def reference?(type)
          [:references, :belongs_to].include? type
        end

        private

        # parse possible attribute options like :limit for string/text/binary/integer, :precision/:scale for decimals or :polymorphic for references/belongs_to
        # when declaring options curly brackets should be used
        def parse_type_and_options(type)
          case type
            when /(string|text|binary|integer)\{(\d+)\}/
              return $1, limit: $2.to_i
            when /decimal\{(\d+)[,.-](\d+)\}/
              return :decimal, precision: $1.to_i, scale: $2.to_i
            when /(references|belongs_to)\{(.+)\}/
              type = $1
              provided_options = $2.split(/[,.-]/)
              options = Hash[provided_options.map { |opt| [opt.to_sym, true] }]
              return type, options
            else
              return type, {}
          end
        end
      end

      def initialize(name, type=nil, index_type=false, attr_options={})
        @name           = name
        @type           = type || :string
        @has_index      = INDEX_OPTIONS.include?(index_type)
        @has_uniq_index = UNIQ_INDEX_OPTIONS.include?(index_type)
        @attr_options   = attr_options
      end

      def field_type
        @field_type ||= case type
                          when :integer              then :number_field
                          when :float, :decimal      then :text_field
                          when :time                 then :time_select
                          when :datetime, :timestamp then :datetime_select
                          when :date                 then :date_select
                          when :text                 then :text_area
                          when :boolean              then :check_box
                          else
                            :text_field
                        end
      end

      def default
        @default ||= case type
                       when :integer                     then 1
                       when :float                       then 1.5
                       when :decimal                     then "9.99"
                       when :datetime, :timestamp, :time then Time.now.to_s(:db)
                       when :date                        then Date.today.to_s(:db)
                       when :string                      then name == "type" ? "" : "MyString"
                       when :text                        then "MyText"
                       when :boolean                     then false
                       when :references, :belongs_to     then nil
                       else
                         ""
                     end
      end

      def plural_name
        name.sub(/_id$/, '').pluralize
      end

      def singular_name
        name.sub(/_id$/, '').singularize
      end

      def human_name
        name.humanize
      end

      def index_name
        @index_name ||= if polymorphic?
                          %w(id type).map { |t| "#{name}_#{t}" }
                        else
                          column_name
                        end
      end

      def column_name
        @column_name ||= reference? ? "#{name}_id" : name
      end

      def foreign_key?
        !!(name =~ /_id$/)
      end

      def reference?
        self.class.reference?(type)
      end

      def polymorphic?
        self.attr_options[:polymorphic]
      end

      def required?
        self.attr_options[:required]
      end

      def has_index?
        @has_index
      end

      def has_uniq_index?
        @has_uniq_index
      end

      def password_digest?
        name == 'password' && type == :digest
      end

      def token?
        type == :token
      end

      def inject_options
        "".tap { |s| options_for_migration.each { |k,v| s << ", #{k}: #{v.inspect}" } }
      end

      def inject_index_options
        has_uniq_index? ? ", unique: true" : ""
      end

      def options_for_migration
        @attr_options.dup.tap do |options|
          if required?
            options.delete(:required)
            options[:null] = false
          end

          if reference? && !polymorphic?
            options[:foreign_key] = true
          end
        end
      end
    end
  end
end
