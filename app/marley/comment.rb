module Marley

  # = Comments for articles
  # .db file is created in Marley::DATA_DIRECTORY (set in <tt>config.yml</tt>)
  class Comment < ActiveRecord::Base
    
    ActiveRecord::Base.establish_connection( :adapter => 'sqlite3', :database => File.join(DATA_DIRECTORY, 'comments.db') )
    
    belongs_to :post

    validates_presence_of :author, :email, :body, :post_id

    before_create :check_spam
    
    private
    
    def check_spam
      result = Marley::Akismet.check( self.ip, self.user_agent, self.referrer, nil, 'comment', self.author, self.email, self.url, self.body, nil )
      puts result.inspect
      if result
        self.checked = true
        self.spam = result
      end
    end
    
  end

end
