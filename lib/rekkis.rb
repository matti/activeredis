
# to be aware of rails & stuff
require 'rubygems'

# latest stuff!
Dir.chdir('redis-rb/lib') do
	require 'redis'
end

# Rails 3.0.0-beta needs to be installed
require 'active_model'


module Rektive
  
  class Base

	  include ActiveModel::Validations
    include ActiveModel::Dirty
    include ActiveModel::Serialization
    include ActiveModel::Serializers::JSON
    include ActiveModel::Naming
    
    
    def initialize(attributes = {})
      attributes.stringify_keys!   # NEEDS to be strings for railsisms
      @attributes = attributes
     
      (class << self; self; end).class_eval do
         attributes.each_pair do |key, value|
          define_method key.to_sym do
             value
          end
        end
      end
      
    end
    
    # RAILSISM
    # Returns a hash of all the attributes with their names as keys and the values of the attributes as values
    #  --> means: Strings as keys!
    #  --> initialize stringifies
    #
    #  called by to_json for_example
    
    def attributes
      @attributes
    end
    
    
    # def self.inherited(child)
    #   @@redis = Redis.new
    #   @@class = child
    # end
  end
end
