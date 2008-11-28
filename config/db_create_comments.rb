# Inspired by Ryan Tomayko, http://github.com/rtomayko/wink/tree/master/lib/wink/models.rb#L276
ActiveRecord::Schema.define(:version => 1) do
  create_table :comments do |t|
    t.string :post_id, :null => false
    t.string :author, :email, :url, :ip, :referrer , :user_agent, :referrer, :permalink, :comment_type
    t.text   :body
    t.datetime :created_at, :default => 'NOW()'
    t.boolean  :checked, :default => false
    t.boolean  :spam,    :default => false
  end
  add_index :comments, :post_id
end