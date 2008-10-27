require File.join(File.dirname(__FILE__), '..', '..', 'vendor/akismet')    # ... filter spam from ham
require File.join(File.dirname(__FILE__), '..', '..', 'vendor/akismetor')  # ... filter spam from ham

module Marley

  # = Interface to Akismet checking library
  # TODO : Cleanup
  class Akismet
    # def self.check( ip, user_agent, referrer, permalink, comment_type, author, email, url, body, other )
    #   akismet = ::Akismet.new(::CONFIG['akismet']['key'], ::CONFIG['akismet']['url'])
    #   raise ArgumentError, "Invalid Akismet key" unless akismet.verifyAPIKey
    #   akismet.commentCheck(ip, user_agent, referrer, permalink, comment_type, author, email, url, body, other)
    # end

    def self.check
      
    end
  end
  
end
