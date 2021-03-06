# to be aware of rails & stuff
require 'rubygems'

# latest stuff!
Dir.chdir('redis-rb/lib') do
  require 'redis'
end

# Rails 3.0.0-beta needs to be installed
require 'active_model'

module ActiveRedis
  
  class ActiveRedisError < StandardError
  end
  
  # Raised when Active Redis cannot find record by given id or set of ids.
  class RecordNotFound < ActiveRedisError
  end
  
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
    
    def initialize(attributes = {}, id = nil)
      @id = id if id
      @attributes = {}
      initialize_attributes(attributes)
    end
    
    # Object's attributes' keys are converted to strings because of railsisms.
    # Because of activeredisism, also values are converted to strings for consistency.
    def initialize_attributes(attributes)
      attributes.stringify_keys!   # NEEDS to be strings for railsisms
      attributes.each_pair { |key, value| attributes[key] = value.to_s }
      @attributes.merge!(attributes)

      (class << self; self; end).class_eval do
        attributes.each_pair do |key, value|
          define_method key.to_sym do
            value
          end
          define_method "#{key}=".to_sym do |new_value|
            @attributes["#{key}"] = new_value.to_s
          end
        end
      end
    end

    def save
      attributes_array = attributes.to_a.flatten
      creation = new_record?
      
      @id = self.class.fetch_new_identifier if creation

      connection.multi do

        if attributes_array.size > 0  
          connection.call_command(["hmset", "#{key_namespace}:attributes"] + attributes_array)
        end

        connection.zadd("#{class_namespace}:all", @id, @id) 
        
      end
            
      return true
    end
    
    def new_record?
      @id == nil
    end
    
    def key_namespace
      "#{self.class.key_namespace}:#{self.id}"
    end
    
    def class_namespace
      "#{self.class.key_namespace}"
    end
    
    def connection
      self.class.connection
    end
    
    def delete
      connection.multi do
        connection.del "#{key_namespace}:attributes"
        connection.zrem "#{class_namespace}:all", @id
      end
      
      return true     
    end
    
    def add_attribute(name, value=nil)
      initialize_attributes({name => value})
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
      connection.info # call_command [:info]
    end
    
    def self.connection
      @@redis
    end

    def self.count
      begin
        return connection.zcard "#{key_namespace}:all"
      rescue RuntimeError => e
        return 0
      end
    end

    def self.find(id)
      exists = connection.zscore "#{key_namespace}:all", id
      raise RecordNotFound.new("Couldn't find #{self.name} with ID=#{id}") unless exists
      
      attributes = connection.hgetall "#{key_namespace}:#{id}:attributes"
            
      obj = self.new attributes, id
      
      return obj
    end
  end
end
