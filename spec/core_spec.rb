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
  
  describe "counting" do
    it "should know count of its objects when empty" do
      Cat.count.should == 0
    end

    # Waiting for object persisting
    it "should know count of its objects" 
    # do
    #   @cat.save
    #   Cat.count.should == 1
    # end
    
  end
  
  describe "attributes" do
    
    it "should have attributes" do
      @cat.attributes.should include("name")
    end
  
    it "should have accessors for all attributes" do
      @cat.name.should == "lol"
    end
        
  end
  
  describe "find" do
    
    it "should return nil if record was not found" do
      no_such_cat = Cat.find(1)
      no_such_cat.should be_nil    
    end
    
    
  end

end
