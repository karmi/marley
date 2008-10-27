module Marley

  # = Comments for articles
  # .db file is created in Marley::DATA_DIRECTORY (set in <tt>config.yml</tt>)
  class Comment < ActiveRecord::Base
    
    ActiveRecord::Base.establish_connection( :adapter => 'sqlite3', :database => File.join(DATA_DIRECTORY, 'comments.db') )
    
    belongs_to :post

    validates_presence_of :author, :email, :body, :post_id

    before_create :check_spam
    
    private

    # See http://railscasts.com/episodes/65-stopping-spam-with-akismet
    def akismet_attributes
      {
        :key                  => CONFIG['akismet']['key'],
        :blog                 => CONFIG['akismet']['url'],
        :user_ip              => self.ip,
        :user_agent           => self.user_agent,
        :comment_author       => self.author,
        :comment_author_email => self.email,
        :comment_author_url   => self.url,
        :comment_content      => self.body
      }
    end
    
    def check_spam
      # result = Marley::Akismet.check( self.ip, self.user_agent, self.referrer, nil, 'comment', self.author, self.email, self.url, self.body, nil )
      #       puts result.inspect
      #       if result
      #         self.checked = true
      #         self.spam = result
      #       end
      result = !Akismetor.spam?(akismet_attributes)
      puts result
      self.checked = true
      self.spam = result
      true # return true so it doesn't stop save
    end
    
  end

end
