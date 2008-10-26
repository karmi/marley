require 'rake'

task :default => 'app:start'

namespace :app do

  desc "Install the fresh application"
  task :install do
    # TODO : Copy fixtures into <tt>./data/</tt>, open in Safari on a Mac, etc
    Rake::Task['app:install:create_db'].invoke
  end
  namespace :install do 
    task :create_db do 
      require 'rubygems'
      require 'activerecord'
      ActiveRecord::Base.establish_connection( :adapter => 'sqlite3', :database => './data/development.db')
      load File.join( 'config', 'db_create_comments.rb' )
    end
    task :create_sample_article do
    end
    task :create_sample_comment do
    end
    task :open_in_browser do
    end
  end

  desc 'Start application in development'
  task :start do
    exec "ruby app/marley.rb"
  end

  desc "Deploy application on the server [shortcut for Cap]"
  task :deploy do
    exec "cap deploy"
  end

  desc "Run tests for the application"
  task :test do
    exec "cd app/test; ruby marley_test.rb"
  end
  
end

namespace :blog do
  
  task :sync do
    # TODO : use Git
    exec "cap blog:sync"
  end
    
end

namespace :server do
  
  task :start do
    exec "cd app; thin -R rackup.ru -d -P ../tmp/pids/thin.pid -l log/production.log -e production -p 4500 start"
  end
  
  task :stop do
    exec "thin stop"
  end
  
  task :restart do 
    exec "thin restart"
  end
  
end