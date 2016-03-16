class DialecticMongoidGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)

  desc "Creates a Mongoid model"
  argument :attributes, type: :array, default: [], banner: "field:type field:type"

  check_class_collision

  class_option :timestamps, type: :boolean
  class_option :parent,     type: :string, desc: "The parent class for the generated model"
  class_option :collection, type: :string, desc: "The collection for storing model's documents"

  def create_model_file
    template "model.rb.tt", File.join("lib", class_path, 'mongoid/', "#{file_name}.rb")
  end

  hook_for :test_framework
end

module Rails
  module Generators
    class GeneratedAttribute
      def type_class
        return "Time" if type == :datetime
        return "String" if type == :text
        return "Mongoid::Boolean" if type == :boolean
        type.to_s.camelcase
      end
    end
  end
end