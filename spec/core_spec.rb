require 'lib/active_redis'

class Cat < ActiveRedis::Base
  
end

describe Cat do

  before(:each) do
    @cat = Cat.new(:name => "lol")
  end

  it "should be a rektive model" do
    Cat.ancestors.should include(ActiveRedis::Base)
  end
  
  it "should give out info on the redis server" do
    Cat.redis_information.should be_an_instance_of(Hash)
    Cat.redis_information[:uptime_in_days].should == "0"
  end
  
  it "should have a connection to a redis server" do
    Cat.connection.should be_an_instance_of(Redis::Client)
  end

  describe "counting" do
    it "should know count of its objects when empty" do
      Cat.count.should == 0
    end

    it "should know count of its objects" do
       @cat.save
       Cat.count.should == 1
    end
    
  end
  
  describe "attributes" do
    
    it "should have attributes" do
      @cat.attributes.should include("name")
    end
  
    it "should have accessors for all attributes" do
      @cat.name.should == "lol"
    end
     
    it "should stringify all values" do
      numeric_cat = Cat.new(:age => 25, :length => 5.4)
      numeric_cat.age.should == "25"
      numeric_cat.length.should == "5.4"
    end   
  end
  
  describe "persisting simple objects" do
    before(:each) do
      @cat = Cat.new(:name => "lol",
                     :color => "white")
    end
    
    it "should persist a simple object successfully" do
      @cat.save.should be_true
    end
    
    it "should have a key to fetch the next free identifier from" do
      Cat.identifier_sequencer.should == "Cat:sequence"
    end
    
    it "should reserve a unique identifier for the object" do
      Cat.connection.should_receive(:incr).with(Cat.identifier_sequencer).and_return(1)
      
      Cat.fetch_new_identifier
    end
    
    it "should save the identifier to the object" do
      @cat.save
      
      @cat.id.should_not be_nil
    end
    
    it "should persist the attributes of the object" do
      Cat.stub!(:fetch_new_identifier).and_return(1)
      Cat.connection.stub!(:multi).and_yield

      Cat.connection.should_receive(:call_command).with([ "hmset",
                                                          "#{Cat.key_namespace}:1:attributes",
                                                          "name", "lol",
                                                          "color", "white"]).and_return(true)

      Cat.connection.should_receive(:zadd).with("#{Cat.key_namespace}:all", 1, 1).and_return(true)
      
      @cat.save
    end
    
    it "should have atomic save operations" do
      Cat.stub!(:fetch_new_identifier)
      Cat.connection.should_receive(:multi).and_yield
      Cat.connection.should_receive(:call_command)
      Cat.connection.should_receive(:zadd)
      @cat.save
    end
    
    it "should persist attributeless cat" do
      attributeless = Cat.new
      attributeless.save
      
      attributeless.id.should_not be_nil
    end
    
    
    
  end

  describe "deletion" do
    it "object should remove itself" do
      @cat.save
      
      @cat.delete.should == true
      lambda {
        Cat.find(@cat.id)
      }.should raise_error(ActiveRedis::RecordNotFound)

    end
    
    it "should delete as an atomic operation" do
      dead_cat = Cat.new({}, 1)
      Cat.connection.should_receive(:multi).and_yield
      Cat.connection.should_receive(:del).with("#{Cat.key_namespace}:1:attributes").and_return(10)
      Cat.connection.should_receive(:zrem).with("#{Cat.key_namespace}:all", 1).and_return(1)
      dead_cat.delete.should == true
    end
    
  end
  
  describe "find" do
    
    it "should raise error if record was not found" do
      no_such_cat_id = 99
      lambda { 
        Cat.find(no_such_cat_id)
      }.should raise_error(ActiveRedis::RecordNotFound)
      
    end
    
    it "should check that object exists in all" do
      Cat.connection.should_receive(:zscore).with("#{Cat.key_namespace}:all", 1).and_return(true)
      Cat.find(1)
    end
    
    it "should load all attributes" do
      Cat.connection.stub!(:zscore).and_return(1)
      
      Cat.connection.should_receive(:hgetall).with("#{Cat.key_namespace}:1:attributes").and_return({})                                                    
      Cat.find(1)
    end
    
    it "should find existing cat" do
      attributes_to_persist = {"fur" => "long", "eyes" => "blue"}
      c = Cat.new attributes_to_persist
      c.save
      
      same_cat = Cat.find(c.id)
      same_cat.attributes.should == attributes_to_persist
    end
    
    it "should have id set" do
      existing_cat = Cat.find(1)
      existing_cat.id.should == 1
    end

    it "should find attributeless cat" do
      attributeless = Cat.new
      attributeless.save

      Cat.find(attributeless.id).should_not be_nil
    end

  end
  
  describe "update" do
    
    it "should not create new objects when updating" do
      same_cat = Cat.new
      same_cat.save
      id_before_save = same_cat.id
      
      same_cat.save
      same_cat.id.should == id_before_save
    end
    
  end
  
  
  describe "ActiveModel compatibility" do
  
    it "should respond to new_record?" do
      Cat.new.new_record?.should == true
    end
  end
  
end
