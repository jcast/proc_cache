require File.dirname(__FILE__) + "/spec_helper"

describe ProcCache do
  
  before :each do
    @test = TestObj.new
  end
  
  it "should cache based on arguments" do
    result = @test.with_args(1,2,3)
    @test.time_diff.should >= 1
    result.should == [1,2,3]
    
    result = @test.with_args(1,2,3)
    @test.time_diff.should <= 1
    result.should == [1,2,3]
    
    result = @test.with_args(1,2,4)
    @test.time_diff.should >= 1
    result.should == [1,2,4]
    
    @test.with_args(1,2,4)
    @test.time_diff.should <= 1
    @test.with_args(1,2,3)
    @test.time_diff.should <= 1
  end
  
  it "should cache without arguments" do
    @test.with_args
    @test.time_diff.should >= 1
    
    @test.with_args
    @test.time_diff.should <= 1
  end
  
  it "should cache without arguments and a timeout" do
    result = @test.with_expiration(1,2,3)
    @test.time_diff.should >= 1
    result.should == [1,2,3]
    
    result = @test.with_expiration(4,5,6)
    @test.time_diff.should <= 1
    result.should == [1,2,3]
    
    sleep(4)
    
    @test.with_expiration(1,2,3)
    @test.time_diff.should >= 1
  end
  
  it "should cache with arguments and a timeout" do
    result = @test.with_args_and_expiration(1,2,3)
    @test.time_diff.should >= 1
    result.should == [1,2,3]
    
    result = @test.with_args_and_expiration(4,5,6)
    @test.time_diff.should >= 1
    result.should == [4,5,6]
    
    result = @test.with_args_and_expiration(1,2,3)
    @test.time_diff.should <= 1
    result.should == [1,2,3]
    
    result = @test.with_args_and_expiration(4,5,6)
    @test.time_diff.should <= 1
    result.should == [4,5,6]
    
    sleep(4)
    
    @test.with_args_and_expiration(1,2,3)
    @test.time_diff.should >= 1
    
    @test.with_args_and_expiration(4,5,6)
    @test.time_diff.should >= 1
  end
  
  it "should expire with custom proc condition" do
    result = @test.with_custom_expiration( proc{|*args| args[0] > 1 }, 1,2,3 )
    @test.time_diff.should >= 1
    result.should == [1,2,3]
    
    result = @test.with_custom_expiration( proc{|*args| args[0] > 1 }, -1,4,3 )
    @test.time_diff.should >= 1
    result.should == [-1,4,3]
    
    result = @test.with_custom_expiration( proc{|*args| args[0] > 1 }, 1,2,3 )
    @test.time_diff.should <= 1
    result.should == [1,2,3]

    result = @test.with_custom_expiration( proc{|*args| args[0] > 1 }, -1,4,3 )
    @test.time_diff.should <= 1
    result.should == [-1,4,3]
    
    result = @test.with_custom_expiration( proc{|*args| args[0] > 1 }, 5,2,3 )
    @test.time_diff.should >= 1
    result.should == [5,2,3]
    
    result = @test.with_custom_expiration( proc{|*args| args[0] > 1 }, 1,2,3 )
    @test.time_diff.should >= 1
    result.should == [1,2,3]

    result = @test.with_custom_expiration( proc{|*args| args[0] > 1 }, -1,4,3 )
    @test.time_diff.should >= 1
    result.should == [-1,4,3]
  end
  
end