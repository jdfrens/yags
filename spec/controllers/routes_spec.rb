require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UsersController do

  it "should have login path" do
    login_path.should == "/users/login"
  end

  it "should have logout path" do
    logout_path.should == "/users/logout"
  end
end
