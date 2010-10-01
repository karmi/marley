require File.join(File.dirname(__FILE__), '..', '..', 'vendor', 'akismetor') unless defined? Akismetor

module Marley

  # = Comments for articles
  # .db file is created in Marley::Configuration.data_directory (set in <tt>config.yml</tt>)
  class Comment < ActiveRecord::Base

    belongs_to :post

    scope :recent,   :order => 'created_at DESC', :limit => 50
    scope :ham,  :conditions => { :spam => false }
    scope :spam, :conditions => { :spam => true }

    validates_presence_of :author, :email, :body, :post_id

    before_create :fix_urls, :check_spam

    # No, we won't use +before_destroy+ hook, so we can delete comments without marking them as spam
    def report_as_spam
      Akismetor.submit_spam(akismet_attributes)
    end

    def ham?
      !self.spam?
    end
    
    private

    # See http://railscasts.com/episodes/65-stopping-spam-with-akismet
    def akismet_attributes
      {
        :key                  => Marley::Configuration.akismet.key,
        :blog                 => Marley::Configuration.akismet.url,
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
