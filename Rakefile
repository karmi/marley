require 'rubygems'
require 'activerecord'
require 'rake'
require 'ftools'

MARLEY_ROOT = '.'

%w{configuration post comment}.each { |f| require File.join(MARLEY_ROOT, 'app', 'lib', f) }

desc "Start application in development"
task :default => 'app:start'
desc "Run tests"
task :test    => 'app:test'

namespace :app do

  desc "Install the fresh application"
  task :install do
    Rake::Task['app:install:create_data_directory'].invoke
    Rake::Task['app:install:create_database_for_comments'].invoke
    Rake::Task['app:install:create_sample_article'].invoke
    Rake::Task['app:install:create_sample_comment'].invoke
    puts "* Starting application in development mode"
    Rake::Task['app:start'].invoke
  end
  namespace :install do
    task :create_data_directory do
      puts "* Creating data directory in " + Marley::Configuration.data_directory
      FileUtils.mkdir_p( Marley::Configuration.data_directory )
    end
    desc "Create database for comments"
    task :create_database_for_comments do
      puts "* Creating comments SQLite database in #{Marley::Configuration.data_directory}/comments.db"
      ActiveRecord::Base.establish_connection( :adapter => 'sqlite3', 
                                               :database => File.join(Marley::Configuration.data_directory, 'comments.db')
                                             )
      load( File.join( MARLEY_ROOT, 'config', 'db_create_comments.rb' ) )
    end
    task :create_sample_article do
      puts "* Creating sample article"
      FileUtils.cp_r( File.join(MARLEY_ROOT, 'app', 'test', 'fixtures', '001-test-article-one'), Marley::Configuration.data_directory )
    end
    task :create_sample_comment do
      require 'vendor/akismetor'
      puts "* Creating sample comment"
      Marley::Comment.create( :author  => 'John Doe',
                              :email   => 'john@example.com',
                              :body    => 'Lorem ipsum dolor sit amet',
                              :post_id => 'test-article' )
    end
  end

  desc 'Start application in development'
  task :start do
    exec "ruby app/marley.rb"
  end

  desc "Run tests for the application"
  task :test do
    exec "cd app/test; ruby marley_test.rb"
  end
  
end

namespace :data do
  
  desc "Shortcut to sync data with Capistrano `$ cap data:sync`"
  task :sync do
    exec "cap data:sync"
  end
    
end

namespace :server do
  
  desc "Start server in production on Thin, port 4500"
  task :start do
    exec "thin --rackup config/config.ru --daemonize --log log/thin.log --pid tmp/pids/thin.pid --environment production --port 4500 start && echo '> Marley started on http://localhost:4500'"
  end
  
  desc "Stop server in production"
  task :stop do
    exec "thin --pid tmp/pids/thin.pid stop"
  end
  
  desc "Restart server in production"
  task :restart do 
    exec "thin --pid tmp/pids/thin.pid restart"
  end
  
end
