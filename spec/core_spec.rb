require 'lib/rekkis'

class Cat < Rekkis::Base
  
end

describe Cat do
  it "should be a rektive model" do
    Cat.ancestors.should include(Rekkis::Base)
  end
  
  it "should give out info on the redis server" do
    Cat.redis_information.should be_an_instance_of(Hash)
    Cat.redis_information[:uptime_in_days].should == "0"
  end

  describe "attributes" do
    before(:each) do
      @cat = Cat.new(:name => "lol")
    end
    
    it "should have attributes" do
      @cat.attributes.should include("name")
    end
  
    it "should have accessors for all attributes" do
      @cat.name.should == "lol"
    end
  end
end
