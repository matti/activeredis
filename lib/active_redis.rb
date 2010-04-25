# to be aware of rails & stuff
require 'rubygems'

# latest stuff!
Dir.chdir('redis-rb/lib') do
  require 'redis'
end

# Rails 3.0.0-beta needs to be installed
require 'active_model'

module ActiveRedis
  class Base
    include ActiveModel::Validations
    include ActiveModel::Dirty
    include ActiveModel::Serialization
    include ActiveModel::Serializers::JSON
    include ActiveModel::Naming
    
    # RAILSISM
    # Returns a hash of all the attributes with their names as keys and the values of the attributes as values
    #  --> means: Strings as keys!
    #  --> initialize stringifies
    #
    #  called by to_json for_example
    attr_reader :attributes
    attr_reader :id
    
    # INSTANCE METHODS
    
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

    def save
      attributes_array = attributes.to_a.flatten

      @id = self.class.fetch_new_identifier      
      connection.call_command(["hmset", "#{key_namespace}:attributes"] + attributes_array)
      
      return true
    end
    
    def key_namespace
      "#{self.class.key_namespace}:#{self.id}"
    end
    
    def connection
      self.class.connection
    end
    
    # CLASS METHODS
    
    def self.key_namespace
      "#{self}"
    end
    
    def self.fetch_new_identifier
      self.connection.incr self.identifier_sequencer
    end
    
    def self.identifier_sequencer
      "#{key_namespace}:sequence"
    end
    
    def self.inherited(child)
      @@redis = Redis.new
      @@class = child
    end
    
    def self.redis_information
      @@redis.info # call_command [:info]
    end
    
    def self.connection
      @@redis
    end

    def self.count
      begin
        return @@redis.zcard "#{self.name}:all"
      rescue RuntimeError => e
        return 0
      end
    end

    def self.find(id)
      attributes = @@redis.hgetall "#{key_namespace}:#{id}:attributes"
      return nil if attributes.nil? || attributes == {}
      
      Cat.new attributes
    end
  end
end
