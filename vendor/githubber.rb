require 'net/http'
require 'yaml'
require 'timeout'

# = Ultra minimal interface to Github API

class Githubber

  def initialize(working_copy_path)
    remotes  = %x[cd #{working_copy_path}; git remote -v 2>&1] rescue nil
    return nil unless $?.success?
    origin = remotes.select { |l| l =~ /^origin.*/ }.first
    @user, @repo = origin.to_s.scan(/\S+[:\/]+?(\S+)?\/(\S+)?\.git$/).first
  end

  # Returns revision info
  # Eg. http://github.com/defunkt/gist/commit/bbf57b44784dde90e3dd7ea626a12fc00d4e3465
  def revision(number=nil)
    return nil if number.nil? || @user.nil? || @repo.nil?
    info = execute( "commit/#{number}" )
    return nil unless info
    YAML.load(info)['commit'] rescue nil
  end

  private

  # Modeled after Akismetor (http://railscasts.com/episodes/65-stopping-spam-with-akismet)
  def execute(command)
    begin
      puts "* Executing command '#{command}' for the Github API"
      Timeout.timeout(35) do
        http = Net::HTTP.new("github.com", 80)
        response, content = http.get("/api/v1/yaml/#{@user}/#{@repo}/#{command}")
        content
      end
    rescue Exception => e
      puts "[!] Error when connecting to Github API (Message: #{e.message})"
      nil
    end
  end
  
end

if $0 == __FILE__
  g = Githubber.new({:user => 'karmi', :repo => 'marley'})
  puts g.revision('12956a3').inspect
end