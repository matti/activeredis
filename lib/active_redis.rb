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
    
    def initialize(attributes = {}, id = nil)
      attributes.stringify_keys!   # NEEDS to be strings for railsisms
      @attributes = attributes
      @id = id if id
      
      (class << self; self; end).class_eval do
         attributes.each_pair do |key, value|
          define_method key.to_sym do
             value.to_s
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
      return nil unless exists
      
      attributes = connection.hgetall "#{key_namespace}:#{id}:attributes"
            
      obj = self.new attributes, id
      
      return obj
    end
  end
end
