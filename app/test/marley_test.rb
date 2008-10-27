require 'rubygems'
require 'rack'
require 'sinatra'
require 'sinatra/test/unit'

# Redefine data directory for tests
module Marley
  DATA_DIRECTORY = File.join(File.dirname(__FILE__), 'fixtures')
end

# Require application file
require '../marley'

# Redefine database with comments for tests
module Marley
  class Comment < ActiveRecord::Base
    ActiveRecord::Base.establish_connection( :adapter => 'sqlite3', :database => './fixtures/test.db' )
  end
end

# Setup fresh comments table
File.delete('./fixtures/test.db') if File.exists?('./fixtures/test.db')
ActiveRecord::Base.establish_connection( :adapter => 'sqlite3', :database => './fixtures/test.db')
load File.join( '..', '..', 'config', 'db_create_comments.rb' )


class MarleyTest < Test::Unit::TestCase

  configure do
    set_options :views => File.join( File.dirname(__FILE__), '..', 'views' )
  end

  def test_should_show_index_page
    get_it '/'
    assert @response.status == 200
  end

  def test_should_show_article_page
    get_it '/test-article.html'
    # puts @response.inspect
    assert @response.status == 200
    # assert @response.body =~ /<h1>\n\s*This is the test article<\/h1>/ # Fix it later
  end

  def test_should_send_404
    get_it '/i-am-not-here.html'
    assert @response.status == 404
  end

  def test_should_create_comment
    comment_count = Marley::Comment.count
    post_it '/test-article/comments', { :ip => "127.0.0.1",
                                        :user_agent => "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_5_4; en-us)",
                                        :body => "Testing comments...",
                                        :post_id => "test-article",
                                        :url => "",
                                        :author => 'Tester',
                                        :email => "tester@localhost" }
    assert @response.status == 302
    assert Marley::Comment.count == comment_count + 1
  end

  def test_should_show_feed
    get_it '/feed'
    assert @response.status == 200
  end

end