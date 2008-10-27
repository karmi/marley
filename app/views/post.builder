xml.instruct! :xml, :version => '1.0'
xml.feed :'xml:lang' => 'en-US', :xmlns => 'http://www.w3.org/2005/Atom' do
  xml.id "tag:#{hostname},:/#{@post.id}/feed"
  xml.link :type => 'text/html', :href => "http://#{hostname}/#{@post.id}.html", :rel => 'alternate'
  xml.link :type => 'application/atom+xml', :href => "http://#{hostname}/#{@post.id}/feed", :rel => 'self'
  xml.title "Comments on „#{@post.title}“ #{CONFIG['blog']['name']}"
  xml.subtitle  "#{hostname}/#{@post.id}.html"
  xml.updated(@post.comments.last ? @post.comments.last.created_at : Time.now.utc) if @post.comments.last
  @post.comments.each_with_index do |comment, index|
    xml.entry do |entry|
      entry.id
      entry.link :type => 'text/html', :href => "http://#{hostname}/#{@post.id}.html#comment_#{index}", :rel => 'alternate'
      entry.title "#{h comment.author} said on #{h human_date(comment.created_at)}"
      entry.content :type => 'html' do
        entry.text! h(comment.body)
      end
    end
  end
end
