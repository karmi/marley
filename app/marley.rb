require 'rubygems'
require 'ftools'           # ... we wanna access the filesystem ...
require 'yaml'             # ... use YAML for configs and stuff ...
require 'sinatra'          # ... Classy web-development dressed in DSL, http://sinatrarb.heroku.com
require 'activerecord'     # ... or Datamapper? What? :)
require 'rdiscount'        # ... convert Markdown into HTML in blazing speed
require File.join(File.dirname(__FILE__), '..', 'vendor', 'akismetor')   # ... disable comment spam
require File.join(File.dirname(__FILE__), '..', 'vendor', 'githubber')   # ... get repo info

# ... or alternatively, run Sinatra on edge ...
# $:.unshift File.dirname(__FILE__) + 'vendor/sinatra/lib'
# require 'sinatra'

CONFIG = YAML.load_file( File.join(File.dirname(__FILE__), '..', 'config', 'config.yml') ) unless defined? CONFIG
REVISION_NUMBER = File.read( File.join(File.dirname(__FILE__), '..', 'REVISION') ) rescue nil unless defined?(REVISION_NUMBER)

# -----------------------------------------------------------------------------

module Marley
  # Override this as you wish in <tt>config/config.yml</tt>
  DATA_DIRECTORY = File.join(File.dirname(__FILE__), '..', CONFIG['data_directory']) unless defined? DATA_DIRECTORY
  unless defined?(REVISION)
    REVISION = REVISION_NUMBER ? Githubber.new({:user => 'karmi', :repo => 'marley'}).revision( REVISION_NUMBER.chomp ) : nil
  end
end

# FIXME : There must be a clean way to do this :)
req_or_load = (Sinatra.env == :development) ? :load : :require
%w{post.rb comment.rb}.each { |f| send(req_or_load, File.join(File.dirname(__FILE__), 'marley', f) ) }

# -----------------------------------------------------------------------------

configure do
  set_options :session => true
end

configure :production do
  not_found { not_found }
  error     { error }
end

helpers do
  
  include Rack::Utils
  alias_method :h, :escape_html

  def markup(string)
    RDiscount::new(string).to_html
  end
  
  def human_date(datetime)
    datetime.strftime('%d|%m|%Y').gsub(/ 0(\d{1})/, ' \1')
  end

  def rfc_date(datetime)
    datetime.strftime("%Y-%m-%dT%H:%M:%SZ") # 2003-12-13T18:30:02Z
  end

  def hostname
    (request.env['HTTP_X_FORWARDED_SERVER'] =~ /[a-z]*/) ? request.env['HTTP_X_FORWARDED_SERVER'] : request.env['HTTP_HOST']
  end

  def revision
    Marley::REVISION || nil
  end

  def not_found
    File.read( File.join( File.dirname(__FILE__), 'public', '404.html') )
  end

  def error
    File.read( File.join( File.dirname(__FILE__), 'public', '500.html') )
  end

end

# -----------------------------------------------------------------------------

get '/' do
  @posts = Marley::Post.published
  @page_title = "#{CONFIG['blog']['title']}"
  erb :index
end

get '/feed' do
  @posts = Marley::Post.published
  last_modified( @posts.first.updated_on )           # Conditinal GET, send 304 if not modified
  builder :index
end

get '/feed/comments' do
  @comments = Marley::Comment.recent.ham
  last_modified( @comments.first.created_at )        # Conditinal GET, send 304 if not modified
  builder :comments
end

get '/:post_id.html' do
  @post = Marley::Post[ params[:post_id] ]
  throw :halt, [404, not_found ] unless @post
  @page_title = "#{@post.title} #{CONFIG['blog']['name']}"
  erb :post 
end

post '/:post_id/comments' do
  @post = Marley::Post[ params[:post_id] ]
  throw :halt, [404, not_found ] unless @post
  params.merge!( {
      :ip         => request.env['REMOTE_ADDR'].to_s,
      :user_agent => request.env['HTTP_USER_AGENT'].to_s,
      :referrer   => request.env['REFERER'].to_s,
      :permalink  => "#{hostname}#{@post.permalink}"
  } )
  # puts params.inspect
  @comment = Marley::Comment.create( params )
  if @comment.valid?
    redirect "/"+params[:post_id].to_s+'.html?thank_you=#comment_form'
  else
    @page_title = "#{@post.title} #{CONFIG['blog']['name']}"
    erb :post
  end
end
get '/:post_id/comments' do 
  redirect "/"+params[:post_id].to_s+'.html#comments'
end

get '/:post_id/feed' do
  @post = Marley::Post[ params[:post_id] ]
  throw :halt, [404, not_found ] unless @post
  last_modified( @post.comments.last.created_at ) if @post.comments.last # Conditinal GET, send 304 if not modified
  builder :post
end


post '/sync' do
  throw :halt, 404 and return if not CONFIG['github_token'] or CONFIG['github_token'].nil?
  unless params[:token] && params[:token] == CONFIG['github_token']
    throw :halt, [500, "You did wrong.\n"] and return
  else
    # Synchronize articles in data directory to Github repo
    system "cd #{CONFIG['data_directory']}; git pull origin master"
  end
end

get '/about' do
  "<p style=\"font-family:sans-serif\">I'm running on Sinatra version " + Sinatra::VERSION + '</p>'
end

# -----------------------------------------------------------------------------