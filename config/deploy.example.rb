# Load Marley configuration
CONFIG = YAML.load_file( File.join(File.dirname(__FILE__), 'config.yml') ) unless defined? CONFIG

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

# ----- Marley tasks ----------------------------------------------------------

namespace :sync do
  namespace :setup do
    task :default do
      upload_data_repository
      add_post_receive_hook_for_data_repository
      add_git_remote_to_data_directory
    end
    task :upload_data_repository do
      top.upload(File.join(CONFIG['data_directory'], '.git'), "#{deploy_to}/articles.git" )
      puts "--- Uploaded Git repository from data directory to '#{deploy_to}/articles.git'\n"
      run "cd #{deploy_to}; git clone articles.git #{CONFIG['data_directory'].split('/').last}"
      puts "--- Initialized Git repository\n"
    end
    task :add_post_receive_hook_for_data_repository do
      post_receive_script   = "#{deploy_to}/articles.git/hooks/post-receive"
      remote_data_directory = File.join(deploy_to, CONFIG['data_directory'].split('/').last)
      hook_command ="export GIT_DIR=.git; cd #{remote_data_directory}; git pull origin master; echo \"[Post-receive] Data directory has been synchronized in #{remote_data_directory}\""
      run "chmod +x #{post_receive_script}; echo '#{hook_command}' >> #{post_receive_script}"
      puts "--- Added post-receive hook for Git repository\n"
    end
    task :add_git_remote_to_data_directory do
      `cd #{CONFIG['data_directory']}; git remote add sync #{user}@#{roles[:app].instance_variable_get(:@static_servers).first.instance_variable_get(:@host)}:#{deploy_to}/articles.git`
      puts "--- Added remote repository 'sync' for data. Use 'git push sync' to synchronize your content.\n"
    end
  end
end

namespace :app do
  desc "Upload configuration file (config/config.yml) to deploy"
  task :upload_config, :roles => :app do
   top.upload('config/config.yml', "#{shared_path}/config.yml" )
  end
end

# ----- Hooks ----------------------------------------------------------------

before "deploy:cold" do
  app.upload_config
end

after "deploy:update_code" do
  # run "ln -nfs #{shared_path}/sinatra #{release_path}/sinatra"
  run "ln -nfs #{shared_path}/config.yml #{release_path}/config/config.yml"
  run "ln -nfs #{deploy_to}/../data #{release_path}/data"
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
<<<<<<< HEAD:config/deploy.example.rb
end
=======

end
>>>>>>> 59b20d8... Added Capistrano task for setting-up remote repository for articles with "autoupdating" post-receive hook:config/deploy.example.rb
