xml.instruct! :xml, :version => '1.0'
xml.feed :'xml:lang' => 'en-US', :xmlns => 'http://www.w3.org/2005/Atom' do
  xml.id "tag:#{hostname},#{@post.published_on.year}:/#{@post.id}/feed"
  xml.link :type => 'text/html', :href => "http://#{hostname}/#{@post.id}.html", :rel => 'alternate'
  xml.link :type => 'application/atom+xml', :href => "http://#{hostname}/#{@post.id}/feed", :rel => 'self'
  xml.title "Comments on „#{@post.title}“ #{Marley::Configuration.blog.title}"
  xml.subtitle  "#{hostname}/#{@post.id}.html"
  xml.updated(@post.comments.last ? rfc_date(@post.comments.last.created_at) : rfc_date(Time.now.utc)) if @post.comments.last
  @post.comments.each_with_index do |comment, index|
    xml.entry do |entry|
      entry.id "tag:#{hostname},#{@post.published_on.strftime('%Y-%m-%d')}:/#{@post.id}/comments/#{comment.created_at.to_i}"
      xml.updated rfc_date(comment.created_at)
      entry.link :type => 'text/html', :href => "http://#{hostname}/#{@post.id}.html#comment_#{index}", :rel => 'alternate'
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
