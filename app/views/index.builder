xml.instruct! :xml, :version => '1.0'
xml.feed :'xml:lang' => 'en-US', :xmlns => 'http://www.w3.org/2005/Atom' do
  xml.id "tag:#{hostname},:/feed"
  xml.link :type => 'text/html', :href => "http://#{request.env['HTTP_X_FORWARDED_SERVER']}", :rel => 'alternate'
  xml.link :type => 'application/atom+xml', :href => "http://#{request.env['HTTP_X_FORWARDED_SERVER']}/feed", :rel => 'self'
  xml.title CONFIG['blog']['title']
  xml.subtitle  "http://#{hostname}"
  xml.updated(@posts.first ? @posts.first.updated_on : Time.now.utc)
  @posts.each do |post|
    xml.entry do |entry|
      entry.id "tag:#{hostname},:/#{post.id}.html"
      entry.link :type => 'text/html', :href => "http://#{hostname}/#{post.id}.html", :rel => 'alternate'
      entry.title post.title
      entry.content :type => 'html' do
        entry.text! post.perex
      end
    end
  end
end
