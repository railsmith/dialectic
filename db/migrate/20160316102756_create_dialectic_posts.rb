class CreateDialecticPosts < ActiveRecord::Migration
  def change
    create_table :dialectic_posts do |t|
      t.string :subject
      t.integer :posted_by
      t.string :body
    end
  end
end