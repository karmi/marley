xml.instruct! :xml, :version => '1.0', :encoding => 'utf-8'
xml.feed :'xml:lang' => 'en-US', :xmlns => 'http://www.w3.org/2005/Atom' do
  xml.id "http://#{hostname}"
  xml.link :type => 'text/html', :href => "http://#{hostname}", :rel => 'alternate'
  xml.link :type => 'application/atom+xml', :href => "http://#{hostname}/feed", :rel => 'self'
  xml.title Marley::Configuration.blog.title
  xml.subtitle "#{h(hostname)}"
  xml.updated(@posts.first ? rfc_date(@posts.first.updated_on) : rfc_date(Time.now.utc))
  @posts.each do |post|
    xml.entry do |entry|
      entry.id "http://#{hostname}/#{post.id}.html"
      entry.link :type => 'text/html', :href => "http://#{hostname}/#{post.id}.html", :rel => 'alternate'
      entry.updated rfc_date(post.updated_on)
      entry.title post.title
      entry.summary post.perex, :type => 'html'
      entry.content post.body,  :type => 'html'
      entry.author do |author|
        author.name  Marley::Configuration.blog.author || hostname
        author.email(Marley::Configuration.blog.email)  if Marley::Configuration.blog.email
      end
    end
  end
end
