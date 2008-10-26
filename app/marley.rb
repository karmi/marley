require 'rubygems'
require 'ftools'          # ... we wanna access the filesystem ...
require 'yaml'            # ... use YAML for configs and stuff ...
require 'sinatra'         # ... Classy web-development dressed in DSL, http://sinatrarb.heroku.com
require 'activerecord'    # ... or Datamapper? What? :)
require 'rdiscount'       # ... convert Markdown into HTML in blazing speed
require File.join(File.dirname(__FILE__), '..', 'vendor/akismet')  # ... filter spam from ham

# ... or alternatively, run Sinatra on edge ...
# $:.unshift File.dirname(__FILE__) + 'vendor/sinatra/lib'
# require 'sinatra'

CONFIG = YAML.load_file( File.join(File.dirname(__FILE__), '..', 'config', 'config.yml') ) unless defined? CONFIG

# -----------------------------------------------------------------------------

module Blog

  # Override this as you wish
  DATA_DIRECTORY = File.join(File.dirname(__FILE__), '..', 'data') unless defined? DATA_DIRECTORY

  # = Articles
  # Data source is DATA_DIRECTORY
  class Post
    
    attr_reader :id, :title, :perex, :body, :body_html, :meta, :published_on, :updated_on, :published, :comments
    
    def initialize(options={})
      options.each_pair { |key, value| instance_variable_set("@#{key}", value) if self.respond_to? key }
    end
  
    def self.all(options={})
      self.find_all options.merge(:draft => true)
    end
    
    def self.published(options={})
      self.find_all options.merge(:draft => false)
    end
  
    def self.[](id, options={})
      self.find_one(id, options)
    end
    
    def categories
      self.meta['categories'] if self.meta and self.meta['categories']
    end
            
    private
    
    def self.find_all(options={})
      options[:except] ||= ['body', 'body_html']
      posts = []
      self.extract_posts_from_directory(options).each do |file|
        attributes = self.extract_post_info_from(file, options)
        attributes.merge!( :comments => Blog::Comment.find_all_by_post_id(attributes[:id], :select => ['id']) )
        posts << self.new( attributes )
      end
      return posts.reverse
    end
    
    def self.find_one(id, options={})
      directory = self.load_directories_with_posts(options).select { |dir| dir =~ Regexp.new("#{id}") }
      options.merge!( {:draft => true} )
      # FIXME : Refactor this mess!
      return if directory.empty?
      directory = directory.first
      return unless directory or !File.exist?(directory)
      file = Dir["#{directory}/*.txt"].first
      self.new( self.extract_post_info_from(file, options).merge( :comments => Blog::Comment.find_all_by_post_id(id) ) )
    end
    
    # Returns directories in data directory. Default is published only (no <tt>.draft</tt> in name)
    def self.load_directories_with_posts(options={})
      if options[:draft]
        Dir[File.join(DATA_DIRECTORY, '*')].select { |dir| File.directory?(dir)  }.sort
      else
        Dir[File.join(DATA_DIRECTORY, '*')].select { |dir| File.directory?(dir) and not dir.include?('.draft')  }.sort
      end
    end
    
    # Loads all directories in data directory and returns first <tt>.txt</tt> file in each one
    def self.extract_posts_from_directory(options={})
      self.load_directories_with_posts(options).collect { |dir| Dir["#{dir}/*.txt"].first }.compact
    end
    
    # Extracts post information from the directory name, file contents, modification time, etc
    # Returns hash which can be passed to <tt>Blog::Post.new()</tt>
    # Extracted attributes can be configured with <tt>:except</tt> and <tt>:only</tt> options
    def self.extract_post_info_from(file, options={})
      raise ArgumentError, "#{file} is not a readable file" unless File.exist?(file) and File.readable?(file)
      options[:except] ||= []
      options[:only]   ||= Blog::Post.instance_methods # FIXME: Refaktorovat!!
      dirname       = File.dirname(file).split('/').last
      file_content  = File.read(file)
      meta_content  = file_content.slice!( self.regexp[:meta] )
      body          = file_content.sub( self.regexp[:title], '').sub( self.regexp[:perex], '').strip
      post          = Hash.new
      # TODO: Cleanup regexp for ID
      post[:id]           = dirname.sub(self.regexp[:id], '\1').sub(/\.draft$/, '')
      post[:title]        = file_content.scan( self.regexp[:title] ).to_s.strip       unless options[:except].include? 'title' or 
                                                                                      not options[:only].include? 'title'
      post[:perex]        = file_content.scan( self.regexp[:perex] ).first.to_s.strip unless options[:except].include? 'perex' or
                                                                                      not options[:only].include? 'perex'
      post[:body]         = body                                                      unless options[:except].include? 'body' or
                                                                                      not options[:only].include? 'body'
      post[:body_html]    = RDiscount::new( body ).to_html                            unless options[:except].include? 'body_html' or
                                                                                      not options[:only].include? 'body_html'
      post[:meta]         = ( meta_content ) ? YAML::load( meta_content.scan( self.regexp[:meta]).to_s ) : 
                                               nil unless options[:except].include? 'meta' or not options[:only].include? 'meta'
      post[:published_on] = File.mtime( File.dirname(file) )                          unless options[:except].include? 'published_on' or
                                                                                      not options[:only].include? 'published_on'
      post[:updated_on]   = File.mtime( file )                                        unless options[:except].include? 'updated_on' or
                                                                                      not options[:only].include? 'updated_on'
      post[:published]    = !dirname.match(/\.draft$/)                                unless options[:except].include? 'published' or
                                                                                      not options[:only].include? 'published'
      return post
    end
    
    def self.regexp
      { :id    => /^\d{0,4}-{0,1}(.*)$/,
        :title => /^#\s*(.*)$/,
        :perex => /^([^\#\n]+\n)$/, 
        :meta  => /^\{\{\n(.*)\}\}\n$/mi # Multiline Regexp 
      } 
    end
  
  end
  
  # = Comments for articles
  # .db file is created in DATA_DIRECTORY
  class Comment < ActiveRecord::Base
    
    ActiveRecord::Base.establish_connection( :adapter => 'sqlite3', :database => File.join(DATA_DIRECTORY, 'development.db') )
    
    belongs_to :post

    validates_presence_of :author, :email, :body, :post_id

    before_create :check_spam
    
    private
    
    def check_spam
      result = Blog::Akismet.check( self.ip, self.user_agent, self.referrer, nil, 'comment', self.author, self.email, self.url, self.body, nil )
      puts result.inspect
      if result
        self.checked = true
        self.spam = result
      end
    end
    
  end
  
  # = Interface to Akismet checking library
  # TODO : Cleanup
  class Akismet
    def self.check( ip, user_agent, referrer, permalink, comment_type, author, email, url, body, other )
      akismet = ::Akismet.new(::CONFIG['akismet']['key'], ::CONFIG['akismet']['url'])
      raise ArgumentError, "Invalid Akismet key" unless akismet.verifyAPIKey
      akismet.commentCheck(ip, user_agent, referrer, permalink, comment_type, author, email, url, body, other)
    end
  end
  
end

# -----------------------------------------------------------------------------

helpers do
  
  include Rack::Utils
  alias_method :h, :escape_html
  
  def human_date(datetime)
    datetime.strftime('%d|%m|%Y').gsub(/ 0(\d{1})/, ' \1')
  end
  
end

configure do
  set_options :session => true
end

configure :production do
  # 404.html
  not_found do
    File.read( File.join( File.dirname(__FILE__), 'public', '404.html') )
  end
  # 500.html
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
  @posts = Blog::Post.published
  @page_title = "#{CONFIG['blog']['title']}"
  erb :index
end

get '/:post_id.html' do
  @post = Blog::Post[ params[:post_id] ]
  throw :halt, [404, 'Post not found' ] unless @post
  @page_title = "#{@post.title} #{CONFIG['blog']['name']}"
  erb :post 
end

post '/:post_id/comments' do
  @post = Blog::Post[ params[:post_id] ]
  throw :halt, [404, erb(not_found) ] unless @post
  params.merge!( { :ip => request.env['REMOTE_ADDR'], :user_agent => request.env['HTTP_USER_AGENT'] } )
  puts params.inspect
  @comment = Blog::Comment.create( params )
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

post '/sync' do
  puts params
end

get '/about' do
  "<p style=\"font-family:sans-serif\">I'm running on Sinatra version " + Sinatra::VERSION + '</p>'
end

# -----------------------------------------------------------------------------