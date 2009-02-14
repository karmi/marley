require 'yaml'
require 'ostruct'
require 'pathname'

MARLEY_ROOT = File.join(File.expand_path(File.dirname(__FILE__)), '..', '..') unless defined?(MARLEY_ROOT)

module Marley

  # == Wrapping theme related logic
  class Theme

    def initialize(config)
      @config = config
    end

    def name
      @config.theme || default_theme_name
    end

    def directory
      Pathname.new( File.join(themes_directory, name) )
    end

    def views
      Pathname.new( File.join(themes_directory, name, 'views') )
    end

    def public
      Pathname.new( File.join(themes_directory, name, 'public') )
    end

    def default_theme_name
      'default'
    end

    def themes_directory
      Pathname.new( File.join(MARLEY_ROOT, 'themes') )
    end

    def to_s
      name
    end

  end

  # == Wrapping configuration
  class Configuration

    class << self

      # Load configuration form YAML
      def load
        raw_config = YAML.load_file( File.join(MARLEY_ROOT, 'config', 'config.yml') )
        @@config   = nested_hash_to_openstruct(raw_config)
        @@theme   = Theme.new(@@config)
      end

      # Return version info about application
      def revision
        sha = File.read( File.join(MARLEY_ROOT, '..', 'REVISION') ) rescue nil
        sha ? Githubber.new({:user => 'karmi', :repo => 'marley'}).revision( sha.chomp ) : nil
      end

      def data_directory_path
        Pathname.new( File.join(MARLEY_ROOT, data_directory) )
      end

      def theme
        @@theme
      end
      
      # Delegate configuration methods to @@config
      def method_missing(method_name, *attributes)
        if @@config.respond_to?(method_name.to_sym)
          return @@config.send(method_name.to_sym)
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
