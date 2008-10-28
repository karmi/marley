require 'rubygems'
require 'ftools'           # ... we wanna access the filesystem ...
require 'yaml'             # ... use YAML for configs and stuff ...
require 'sinatra'          # ... Classy web-development dressed in DSL, http://sinatrarb.heroku.com
require 'activerecord'     # ... or Datamapper? What? :)
require 'rdiscount'        # ... convert Markdown into HTML in blazing speed
require File.join(File.dirname(__FILE__), '..', 'vendor', 'akismetor') # ... disable comment spam

# ... or alternatively, run Sinatra on edge ...
# $:.unshift File.dirname(__FILE__) + 'vendor/sinatra/lib'
# require 'sinatra'

CONFIG = YAML.load_file( File.join(File.dirname(__FILE__), '..', 'config', 'config.yml') ) unless defined? CONFIG

# -----------------------------------------------------------------------------

module Marley
  # Override this as you wish in <tt>config/config.yml</tt>
  DATA_DIRECTORY = File.join(File.dirname(__FILE__), '..', CONFIG['data_directory']) unless defined? DATA_DIRECTORY
end

%w{post comment}.each { |f| require File.join(File.dirname(__FILE__), 'marley', f) }

# -----------------------------------------------------------------------------

helpers do
  
  include Rack::Utils
  alias_method :h, :escape_html
  
  def human_date(datetime)
    datetime.strftime('%d|%m|%Y').gsub(/ 0(\d{1})/, ' \1')
  end

  def rfc_date(datetime)
    datetime.strftime("%Y-%m-%dT%H:%M:%SZ") # 2003-12-13T18:30:02Z
  end

  def hostname
    (request.env['HTTP_X_FORWARDED_SERVER'] =~ /[a-z]*/) ? request.env['HTTP_X_FORWARDED_SERVER'] : request.env['HTTP_HOST']
  end
  
end

configure do
  set_options :session => true
end

configure :production do
  not_found do
    File.read( File.join( File.dirname(__FILE__), 'public', '404.html') )
  end
  error do
    File.read( File.join( File.dirname(__FILE__), 'public', '500.html') )
  end
end

# -----------------------------------------------------------------------------

# Temporary, splash page
get '/' do
  File.read( File.join( File.dirname(__FILE__), 'public', 'index.html') )
end
# Temporary, splash page
get '/index' do
  @posts = Marley::Post.published
  @page_title = "#{CONFIG['blog']['title']}"
  erb :index
end

get '/:post_id.html' do
  @post = Marley::Post[ params[:post_id] ]
  throw :halt, [404, 'Post not found' ] unless @post
  @page_title = "#{@post.title} #{CONFIG['blog']['name']}"
  erb :post 
end

post '/:post_id/comments' do
  @post = Marley::Post[ params[:post_id] ]
  throw :halt, [404, erb(not_found) ] unless @post
  params.merge!( { :ip => request.env['REMOTE_ADDR'], :user_agent => request.env['HTTP_USER_AGENT'] } )
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

get '/feed' do
  @posts = Marley::Post.published
  last_modified( @posts.first.updated_on )        # Conditinal GET, send 304 if not modified
  builder :index
end

get '/:post_id/feed' do
  @post = Marley::Post[ params[:post_id] ]
  throw :halt, [404, erb(not_found) ] unless @post
  last_modified( @post.comments.last.created_at ) if @post.comments.last # Conditinal GET, send 304 if not modified
  builder :post
end


post '/sync' do
  puts params
end

get '/about' do
  "<p style=\"font-family:sans-serif\">I'm running on Sinatra version " + Sinatra::VERSION + '</p>'
end

# -----------------------------------------------------------------------------