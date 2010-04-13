module SessionHelpers

  def user_session(privilege)
    case privilege
    when :steve, :not_manage_student
      { :current_user_id => 1 }
    when :jeremy
      { :current_user_id => 3 }
    when :randy
      { :current_user_id => 4 }
    when :mendel
      { :current_user_id => 5 }
    when :darwin
      { :current_user_id => 6 }
    when :manage_student
      { :current_user_id => 5 }
    when :calvin, :manage_instructor
      { :current_user_id => 2 }
    when :keith
      { :current_user_id => 7 }
    else
      raise "#{privilege} is not a recognized privilege"
    end
  end

  def logged_in?
    session[:current_user_id] != nil
  end

  def assert_redirected_to_login
    assert_redirected_to :controller => 'users', :action => 'login'
  end

end
