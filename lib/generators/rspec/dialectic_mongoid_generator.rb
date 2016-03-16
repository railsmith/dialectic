module Rspec
  module Generators
    class DialecticMongoidGenerator < Rails::Generators::NamedBase

      source_root File.expand_path('../templates', __FILE__)

      argument :attributes,
               :type => :array,
               :default => [],
               :banner => "field:type field:type"
      class_option :fixture, :type => :boolean

      def create_model_spec
        template_file = File.join(
            'spec/dummy/spec/models/mongoid',
            class_path,
            "#{file_name}_spec.rb"
        )
        template 'model_spec.rb', template_file
      end

      hook_for :fixture_replacement

      def create_fixture_file
        return unless missing_fixture_replacement?
        template 'fixtures.yml', File.join('spec/fixtures', "#{table_name}.yml")
      end

      def type_metatag(type = {})
        if has_1_9_hash_syntax?
          "type: :#{type}"
        else
          ":type => :#{type}"
        end
      end

      def has_1_9_hash_syntax?
        ::Rails::VERSION::STRING > '4.0'
      end

      private

      def missing_fixture_replacement?
        options[:fixture] && options[:fixture_replacement].nil?
      end
    end
  end
end
