ActionController::Routing::Routes.draw do |map|

  map.login "/users/login", :controller => "users", :action => "login"
  map.logout "/users/logout", :controller => "users", :action => "logout"

  map.namespace :instructor do |instructor|
    instructor.resources :courses
  end

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
end
