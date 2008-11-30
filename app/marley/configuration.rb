module Marley

  module Configuration

    # Override this as you wish in <tt>config/config.yml</tt>
    DATA_DIRECTORY = File.join(MARLEY_ROOT, CONFIG['data_directory']) unless defined?(DATA_DIRECTORY)
    
    unless defined?(REVISION)
      REVISION_NUMBER = File.read( File.join(MARLEY_ROOT, '..', 'REVISION') ) rescue nil
      REVISION = REVISION_NUMBER ? Githubber.new({:user => 'karmi', :repo => 'marley'}).revision( REVISION_NUMBER.chomp ) : nil
    end
    
    THEMES_DIRECTORY = File.join(MARLEY_ROOT, 'themes') unless defined?(THEMES_DIRECTORY)
    
    DEFAULT_THEME = "default" unless defined?(DEFAULT_THEME)

    def self.directory_for_theme(theme_name)
      File.join(THEMES_DIRECTORY, theme_name)
    end

  end

end
