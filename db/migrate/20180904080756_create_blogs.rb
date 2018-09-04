class CreateBlogs < ActiveRecord::Migration[5.2]
  def change
    create_table :blogs do |t|
      t.string :title
      t.text :body
      t.string :category
      t.string :auther

      t.timestamps
    end
  end
end
