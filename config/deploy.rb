load File.join(File.dirname(__FILE__), '..', 'vendor', 'plugins', 'lwt_deployment', 'recipes')

set :application, "yags"
set :repository_host, "csforge.calvin.edu"
set(:repository) { "https://#{repository_host}/svn/#{application}/#{repository_path}" }

# Used for web.disable and web.enable
role :web, "yags.calvin.edu"
# Used for deploy.start, deploy.stop, deploy.restart
role :app, "yags.calvin.edu"
# Used for deploy.migrate
role :db, "yags.calvin.edu", :primary => true
