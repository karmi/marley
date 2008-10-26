# ----- Setup SSH -------------------------------------------------------------
set :user, "{REPLACE WITH YOUR SSH USERNAME}"
# -----------------------------------------------------------
# set :password, "REPLACE WITH YOUR PASSWORD or USE SSH KEYS"
# -----------------------------------------------------------
# ssh_options[:port] = {SET THIS IF YOU USE NON STANDARD PORT}


# ----- Setup Git -------------------------------------------------------------
set :runner, "deployer"
set :application, 'marley'
set :scm, :git
# set :branch, "deploy"
set :git_enable_submodules, 1
set :repository,  "{REPLACE WITH YOUR REPOSITORY}"
set :deploy_via, :remote_cache
set :deploy_to, "{REPLACE WITH YOUR PATH}/#{application}"
set :use_sudo, false

# ----- Setup servers, paths and callbacks ------------------------------------
role :app, "{REPLACE WITH YOUR SERVER}"
role :web, "{REPLACE WITH YOUR SERVER}"
role :db,  "{REPLACE WITH YOUR SERVER}", :primary => true

# ----- Specific tasks --------------------------------------------------------

namespace :data do
  task :sync, :roles => :app do
    # TODO
    # upload "../data", "#{deploy_to}/../data"
  end
end

# ----- Hooks ----------------------------------------------------------------
after "deploy:update_code" do
  # run "ln -nfs #{shared_path}/sinatra #{release_path}/sinatra"
  run "ln -nfs #{shared_path}/config.yml #{release_path}/config/config.yml"
  run "ln -nfs #{deploy_to}/../data #{release_path}/data"
end
after "deploy:cold" do
  run "cd #{current_path}; rake app:install:create_data_directory; rake app:install:create_database; rake app:install:create_sample_article"
end

# ----- Over-ride deploy tasks ------------------------------------------------

namespace :deploy do
  
  desc "Deploy new version of application on server"
  task :default, :roles => :app do
    transaction do 
      stop
      update
      start
    end
  end
  
  desc "Deploy new application on server"
  task :cold do
    update
    start
  end
  
  desc "Return to previous version"
  task :rollback do
    stop
    rollback_code
    start
  end

  desc "Restart the webserver"  
  task :restart, :roles => :app do
     run "cd #{current_path}; rake server:restart"
  end
  
  desc "Start the webserver"  
  task :start, :roles => :app do
     run "cd #{current_path}; rake server:start"
  end
  
  desc "Stop the webserver"  
  task :stop, :roles => :app do
     run "cd #{current_path}; rake server:stop"
  end
end