require 'active_support/dependencies'
require 'dialectic/engine'


module Dialectic
  mattr_accessor :orm

   def self.configure
     yield self
   end
end
