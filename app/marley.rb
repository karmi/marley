MARLEY_ROOT = File.join(File.expand_path(File.dirname(__FILE__)), '..') unless defined?(MARLEY_ROOT)

# $LOAD_PATH.unshift File.join( File.dirname(__FILE__), '..', 'vendor/sinatra-sinatra/lib' ) # Edge Sinatra
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'vendor')

require 'rubygems'
require 'ftools'
require 'yaml'
require 'sinatra'
require 'activerecord'
require 'rdiscount'
require 'akismetor'
require 'githubber'

%w{
configuration
post
comment
}.each { |f| require File.join(File.dirname(__FILE__), 'lib', f) }

# -----------------------------------------------------------------------------

configure do
  # Establish database connection
  ActiveRecord::Base.establish_connection(
    :adapter => 'sqlite3',
    :database => File.join(Marley::Configuration.data_directory, 'comments.db')
  )
  # Set paths to views and public
  set :views  => Marley::Configuration.theme.views.to_s
  set :public => Marley::Configuration.theme.public.to_s
end

configure :development, :production do
  # Create database and schema for comments if not present
  unless Marley::Comment.table_exists?
    puts "* Creating comments SQLite database in #{Marley::Configuration.data_directory}/comments.db"
    load( File.join( MARLEY_ROOT, 'config', 'db_create_comments.rb' ) )
  end
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

  def not_found
    File.read( File.join( Sinatra::Application.public, '404.html') )
  end

  def error
    File.read( File.join( Sinatra::Application.public, '500.html') )
  end

  def config
    Marley::Configuration
  end

  def revision
    Marley::Configuration.revision || nil
  end

  def protected!
    response['WWW-Authenticate'] = %(Basic realm="Marley Administration") and \
    throw(:halt, [401, "Not authorized\n"]) and \
    return unless authorized?
  end

  def authorized?
    return false unless Marley::Configuration.admin.username && Marley::Configuration.admin.password
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == [Marley::Configuration.admin.username, Marley::Configuration.admin.password]
  end

end

# -----------------------------------------------------------------------------

get '/' do
  @posts = Marley::Post.published
  @page_title = "#{Marley::Configuration.blog.title}"
  erb :index
end

get '/feed' do
  @posts = Marley::Post.published
  last_modified( @posts.first.updated_on ) rescue nil    # Conditinal GET, send 304 if not modified
  builder :index
end

get '/feed/comments' do
  @comments = Marley::Comment.recent.ham
  last_modified( @comments.first.created_at ) rescue nil # Conditinal GET, send 304 if not modified
  builder :comments
end

get '/*?/?:post_id.html' do
  redirect "/"+params[:post_id].to_s+'.html' unless params[:splat].first == '' || params[:splat].first == 'admin'
  protected! if params[:splat].first == 'admin'
  @post = Marley::Post[ params[:post_id] ]
  throw :halt, [404, not_found ] unless @post
  @page_title = "#{@post.title} #{Marley::Configuration.blog.name}"
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
    @page_title = "#{@post.title} #{Marley::Configuration.blog.name}"
    erb :post
  end
end

get '/:post_id/comments' do
  redirect "/"+params[:post_id].to_s+'.html#comments'
end

delete '/admin/:post_id/spam' do
  protected!
  @post = Marley::Post[ params[:post_id] ]
  throw :halt, [404, not_found ] unless @post
  params.merge!( {
      :ip         => request.env['REMOTE_ADDR'].to_s,
      :user_agent => request.env['HTTP_USER_AGENT'].to_s,
      :referrer   => request.env['REFERER'].to_s,
      :permalink  => "#{hostname}#{@post.permalink}"
  } )
  spam_ids = params[:spam_comment_ids].is_a?(Array) ? params[:spam_comment_ids] : [ params[:spam_comment_ids] ]
  @comments = Marley::Comment.find( spam_ids )
  @comments.each do |comment|
    comment.report_as_spam if Sinatra::Application.production?
    comment.destroy
  end
  redirect "#{@post.permalink}?spam_deleted=#{@comments.size}#comments"
end

get '/:post_id/feed' do
  @post = Marley::Post[ params[:post_id] ]
  throw :halt, [404, not_found ] unless @post
  last_modified( @post.comments.last.created_at ) if @post.comments.last # Conditinal GET, send 304 if not modified
  builder :post
end

get '/:post_id/*' do
  file = params[:splat].to_s.split('/').last
  redirect "/#{params[:post_id]}.html" unless file
  send_file( Marley::Configuration.data_directory_path.join(params[:post_id], file), :disposition => 'inline' )
end

post '/sync' do
  throw :halt, 404 and return if not Marley::Configuration.github_token or Marley::Configuration.github_token.nil?
  unless params[:token] && params[:token] == Marley::Configuration.github_token
    throw :halt, [500, "You did wrong.\n"] and return
  else
    # Synchronize articles in data directory to Github repo
    system "cd #{Marley::Configuration.data_directory}; git pull origin master"
  end
end

get '/about' do
  "<p style=\"font-family:sans-serif\">I'm running on Sinatra version " + Sinatra::VERSION + '</p>'
end

# -----------------------------------------------------------------------------
