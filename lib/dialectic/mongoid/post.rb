module Dialectic
  class Post
    include Mongoid::Document
    field :subject, type: String
    field :posted_by, type: Integer
    field :body, type: String
  end
end
