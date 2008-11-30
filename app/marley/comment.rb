module Marley

  # = Comments for articles
  # .db file is created in Marley::Configuration::DATA_DIRECTORY (set in <tt>config.yml</tt>)
  class Comment < ActiveRecord::Base

    ActiveRecord::Base.establish_connection( :adapter => 'sqlite3', :database => File.join(Configuration::DATA_DIRECTORY, 'comments.db') )

    belongs_to :post

    named_scope :recent,   :order => 'created_at DESC', :limit => 50
    named_scope :ham, :conditions => { :spam => false }

    validates_presence_of :author, :email, :body, :post_id

    before_create :fix_urls, :check_spam
    
    private

    # See http://railscasts.com/episodes/65-stopping-spam-with-akismet
    def akismet_attributes
      {
        :key                  => CONFIG['akismet']['key'],
        :blog                 => CONFIG['akismet']['url'],
        :user_ip              => self.ip,
        :user_agent           => self.user_agent,
        :referrer             => self.referrer,
        :permalink            => self.permalink,
        :comment_type         => 'comment',
        :comment_author       => self.author,
        :comment_author_email => self.email,
        :comment_author_url   => self.url,
        :comment_content      => self.body
      }
    end
    
    def check_spam
      self.checked = true
      self.spam = Akismetor.spam?(akismet_attributes)
      true # return true so it doesn't stop save
    end

    # TODO : Unit test for this
    def fix_urls
      return unless self.url
      self.url.gsub!(/^(.*)/, 'http://\1') unless self.url =~ %r{^http://} or self.url.empty?
    end
    
  end

end
