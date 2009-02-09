require 'yaml'
require 'ostruct'
require 'pathname'

MARLEY_ROOT = File.join(File.dirname(__FILE__), '..', '..') unless defined?(MARLEY_ROOT)

module Marley

  class Configuration

    class << self

      # Load configuration form YAML
      # TODO : Freeze / Make immutable
      def load
        raw_config = YAML.load_file( File.join(MARLEY_ROOT, 'config', 'config.yml') )
        @@config = nested_hash_to_openstruct(raw_config)
        # puts (@@config.public_methods - Object.public_methods).inspect
      end

      # Return version info about application
      def revision
        sha = File.read( File.join(MARLEY_ROOT, '..', 'REVISION') ) rescue nil
        sha ? Githubber.new({:user => 'karmi', :repo => 'marley'}).revision( sha.chomp ) : nil
      end

      # Full path to data directory
      def data_directory_fullpath
        File.join(MARLEY_ROOT, data_directory)
      end

      # Theme name from config or default
      def theme
        default_theme_name || @@config.theme
      end

      # Pathname-like object for theme
      def theme_directory
        Pathname.new( File.join(themes_directory, theme)  )
      end
      
      # Directory with themes (default is MARLEY_ROOT/themes)
      def themes_directory
        File.join(MARLEY_ROOT, 'themes')
      end

      def default_theme_name
        'default'
      end

      # Delegate config methods
      def method_missing(method_name, *attributes)
        if has = @@config.send(method_name)
          return has
        else
          super
        end
      end

    end

    private

    # Recursively convert nested Hashes into Openstructs
    def self.nested_hash_to_openstruct(obj)
      if obj.is_a? Hash
        obj.each { |key, value| obj[key] = nested_hash_to_openstruct(value) }
        OpenStruct.new(obj)
      else
        return obj
      end
    end

  end
  # Autoload
  Configuration.load

end

# puts Marley::Configuration.blog
# puts Marley::Configuration.blog.title
# puts Marley::Configuration.blog.title.class