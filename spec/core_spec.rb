require 'lib/rekkis'

class Cat < Rekkis::Base
  
end

describe Cat do
  it "should be a rektive model" do
    Cat.ancestors.should include(Rekkis::Base)
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
