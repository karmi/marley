xml.instruct! :xml, :version => '1.0'
xml.feed :'xml:lang' => 'en-US', :xmlns => 'http://www.w3.org/2005/Atom' do
  xml.id "tag:#{request.env['HTTP_HOST']},:/feed"
  xml.link :type => 'text/html', :href => "http://#{request.env['HTTP_HOST']}", :rel => 'alternate'
  xml.link :type => 'application/atom+xml', :href => "http://#{request.env['HTTP_HOST']}/feed", :rel => 'self'
  xml.title CONFIG['blog']['title']
  xml.subtitle  "#{request.env['HTTP_HOST']}"
  xml.updated(@posts.first ? @posts.first.updated_on : Time.now.utc)
  @posts.each do |post|
    xml.entry do |entry|
      entry.id
      entry.link :type => 'text/html', :href => "http://#{request.env['HTTP_HOST']}/#{post.id}.html", :rel => 'alternate'
      entry.title post.title
      entry.content :type => 'html' do
        entry.text! post.perex
      end
    end
  end
end
