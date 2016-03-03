require "dialectic/engine"
require "active_support/dependencies"

module Dialectic
   def self.configure
     yield self
   end
end
