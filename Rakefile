require 'rake'
require 'ftools'

task :default => 'app:start'

namespace :app do

  desc "Install the fresh application"
  task :install do
    Rake::Task['app:install:create_data_directory'].invoke
    Rake::Task['app:install:create_database'].invoke
    Rake::Task['app:install:create_sample_article'].invoke
    Rake::Task['app:install:create_sample_comment'].invoke
    Rake::Task['app:start'].invoke
  end
  namespace :install do
    task :create_data_directory do
      FileUtils.mkdir_p( File.join(File.dirname(__FILE__), '..', 'data') )
    end
    task :create_database do 
      require 'rubygems'
      require 'activerecord'
      ActiveRecord::Base.establish_connection( :adapter => 'sqlite3', 
                                               :database => File.join(File.dirname(__FILE__), '..', 'data', 'comments.db')
                                             )
      load( File.join( File.dirname(__FILE__), 'config', 'db_create_comments.rb' ) )
    end
    task :create_sample_article do
      FileUtils.cp_r( File.join(File.dirname(__FILE__), 'app', 'test', 'fixtures', '001-test-article'), 
                      File.join(File.dirname(__FILE__), '..', 'data') )
    end
    task :create_sample_comment do
      require 'app/marley'
      Marley::Comment.create( :author  => 'John Doe',
                            :email   => 'john@example.com',
                            :body    => 'Lorem ipsum dolor sit amet',
                            :post_id => 'test-article' )
    end
    task :open_in_browser do
      `open http://localhost:4567` if RUBY_PLATFORM =~ /darwin/
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