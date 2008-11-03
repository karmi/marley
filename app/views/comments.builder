xml.instruct! :xml, :version => '1.0'
xml.feed :'xml:lang' => 'en-US', :xmlns => 'http://www.w3.org/2005/Atom' do
  xml.id "tag:#{hostname},comments"
  xml.link :type => 'text/html', :href => "http://#{hostname}", :rel => 'alternate'
  xml.link :type => 'application/atom+xml', :href => "http://#{hostname}/feed/comments", :rel => 'self'
  xml.title "Comments for #{CONFIG['blog']['title']}"
  xml.subtitle  "#{hostname}"
  xml.updated(@comments.first ? rfc_date(@comments.first.created_at) : rfc_date(Time.now.utc)) if @comments.first
  @comments.each_with_index do |comment, index|
    xml.entry do |entry|
      entry.id "tag:#{hostname},#{comment.created_at.strftime('%Y-%m-%d')}:/#{comment.post.id}/comments/#{comment.created_at.to_i}"
      xml.updated rfc_date(comment.created_at)
      entry.link :type => 'text/html', :href => "http://#{hostname}/#{comment.post.id}.html#comment_#{index}", :rel => 'alternate'
      entry.title "#{h comment.author} said on #{h human_date(comment.created_at)}"
      entry.content :type => 'html' do
        entry.text! h(comment.body)
      end
      entry.author do |author|
        author.name  comment.author
        author.uri(comment.url) if comment.url =~ /^[a-z]/
      end
    end
  end
end
