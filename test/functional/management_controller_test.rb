require File.dirname(__FILE__) + '/../test_helper'

class ManagementControllerTest < ActionController::TestCase
  test "routing" do
    assert_routing({:method => :get, :path => "/management"},
                   :controller => "management", :action => "index")
  end
end
