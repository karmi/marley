require 'rubygems'
require 'activerecord'
require 'rake'
require 'ftools'

CONFIG = YAML.load_file( File.join(File.dirname(__FILE__), 'config', 'config.yml') ) unless defined? CONFIG

module Marley
  DATA_DIRECTORY = File.join(File.dirname(__FILE__), CONFIG['data_directory']) unless defined? DATA_DIRECTORY
end

%w{post comment}.each { |f| require File.join(File.dirname(__FILE__), 'app', 'marley', f) }

task :default => 'app:start'

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
      puts "* Creating data directory in " + Marley::DATA_DIRECTORY
      FileUtils.mkdir_p( Marley::DATA_DIRECTORY )
    end
    task :create_database_for_comments do
      puts "* Creating comments SQLite database in #{Marley::DATA_DIRECTORY}/comments.db"
      ActiveRecord::Base.establish_connection( :adapter => 'sqlite3', 
                                               :database => File.join(Marley::DATA_DIRECTORY, 'comments.db')
                                             )
      load( File.join( File.dirname(__FILE__), 'config', 'db_create_comments.rb' ) )
    end
    task :create_sample_article do
      puts "* Creating sample article"
      FileUtils.cp_r( File.join(File.dirname(__FILE__), 'app', 'test', 'fixtures', '001-test-article'), Marley::DATA_DIRECTORY )
    end
    task :create_sample_comment do
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
  
  task :sync do
    # TODO : use Git
    exec "cap data:sync"
  end
    
end

namespace :server do
  
  task :start do
    exec "cd app; thin -R rackup.ru -d -P ../tmp/pids/thin.pid -l ../log/production.log -e production -p 4500 start"
  end
  
  task :stop do
    exec "thin stop"
  end
  
  task :restart do 
    exec "thin restart"
  end
  
end
