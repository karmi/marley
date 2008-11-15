xml.instruct! :xml, :version => '1.0'
xml.feed :'xml:lang' => 'en-US', :xmlns => 'http://www.w3.org/2005/Atom' do
  xml.id "http://#{hostname}/feed/comments"
  xml.link :type => 'text/html', :href => "http://#{hostname}", :rel => 'alternate'
  xml.link :type => 'application/atom+xml', :href => "http://#{hostname}/feed/comments", :rel => 'self'
  xml.title "Comments for #{CONFIG['blog']['title']}"
  xml.subtitle "#{h(hostname)}"
  xml.updated(@comments.first ? rfc_date(@comments.first.created_at) : rfc_date(Time.now.utc)) if @comments.first
  @comments.each_with_index do |comment, index|
    xml.entry do |entry|
      entry.id "http://#{hostname}/#{comment.post.id}.html#comment_#{index}"
      xml.updated rfc_date(comment.created_at)
      entry.link :type => 'text/html', :href => "http://#{hostname}/#{comment.post.id}.html#comment_#{index}", :rel => 'alternate'
      entry.title "#{h comment.author} said on #{h human_date(comment.created_at)}"
      entry.content h(comment.body), :type => 'html'
      entry.author do |author|
        author.name  comment.author
        author.uri(comment.url) if comment.url =~ /^[a-z]/
      end
    end
  end
end
