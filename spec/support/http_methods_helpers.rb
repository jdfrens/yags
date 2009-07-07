module HttpMethodsHelpers

  def assert_xhr_post_only(action, params = {}, session = {})
    assert_rejected_http_methods [:xhr_get, :post, :get], action, params, session
  end

  def assert_rejected_http_methods(rejected_methods, action, params = {}, session = {})
    if rejected_methods.include?(:xhr_get)
      xhr :get, action, params, session
      assert_response 401, "should reject xhr get of action #{action.to_s}"
    end
    if rejected_methods.include?(:xhr_post)
      xhr :post, action, params, session
      assert_response 401, "should reject xhr post of action #{action.to_s}"
    end
    if rejected_methods.include?(:post)
      post action, params, session
      assert_response 401, "should reject normal post of action #{action.to_s}"
    end
    if rejected_methods.include?(:get)
      get action, params, session
      assert_response 401, "should reject normal get of action #{action.to_s}"
    end
  end

  def assert_rjs_redirect(options = {})
    assert_equal "window.location.href = \"/#{options[:controller]}/#{options[:action]}/#{options[:id]}\";", @response.body
  end

end
