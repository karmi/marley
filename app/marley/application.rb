module Marley
  module Application
    # Override this as you wish in <tt>config/config.yml</tt>
    unless defined?(DATA_DIRECTORY)
      DATA_DIRECTORY = File.join(MARLEY_ROOT, CONFIG['data_directory'])
    end
    
    unless defined?(REVISION)
      REVISION_NUMBER = File.read( File.join(MARLEY_ROOT, '..', 'REVISION') ) rescue nil
      REVISION = REVISION_NUMBER ? Githubber.new({:user => 'karmi', :repo => 'marley'}).revision( REVISION_NUMBER.chomp ) : nil
    end
    
    unless defined?(THEMES_DIRECTORY)
      THEMES_DIRECTORY = File.join(MARLEY_ROOT, 'themes')
    end
    
    unless defined?(DEFAULT_THEME)
      DEFAULT_THEME = "default"
    end

    def self.directory_for_theme(theme_name)
      File.join(THEMES_DIRECTORY, theme_name)
    end
  end
end
