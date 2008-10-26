require 'net/http'
require 'yaml'

# = Ultra minimal interface to Github API
# TODO : Use Struct

class Githubber

  def initialize(options={})
    @user = options[:user]
    @repo = options[:repo]
  end

  # Returns revision info
  # Eg. http://github.com/defunkt/gist/commit/bbf57b44784dde90e3dd7ea626a12fc00d4e3465
  def revision(number=nil)
    return nil if number.nil?
    info = execute( "commit/#{number}" )
    return nil unless info
    YAML.load(info)['commit'] rescue nil
  end

  private

  # Modeled after Akismetor (http://railscasts.com/episodes/65-stopping-spam-with-akismet)
  def execute(command)
    # TODO : rescue?
    puts "* Executing command '#{command}' for the Github API"
    http = Net::HTTP.new("github.com", 80)
    response, content = http.get("/api/v1/yaml/#{@user}/#{@repo}/#{command}")
    content
  end
  
end

if $0 == __FILE__
  g = Githubber.new({:user => 'karmi', :repo => 'marley'})
  puts g.revision('12956a3').inspect
end