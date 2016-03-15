module Dialectic
  module ApplicationHelper
    def sub_app(model)
      "dialectic/#{Dialectic.orm}/#{model}".camelize.constantize
    end
  end
end
