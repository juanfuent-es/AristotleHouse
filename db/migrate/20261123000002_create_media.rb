# Files live outside the public folder until the content that uses them is published.
class CreateMedia < ActiveRecord::Migration[8.1]
  def change
    create_table :images, id: :uuid do |t|
      t.string :title, null: false, default: ""
      t.string :alt, null: false, default: ""
      t.string :file, null: false, default: ""
      t.string :published_file
      t.integer :width, null: false, default: 0
      t.integer :height, null: false, default: 0
      t.timestamps
      t.index "lower(title)", unique: true, name: "index_images_on_title"
    end

    create_table :videos, id: :uuid do |t|
      t.string :title, null: false, default: ""
      t.string :file, null: false, default: ""
      t.string :published_file
      t.integer :width, null: false, default: 0
      t.integer :height, null: false, default: 0
      t.timestamps
      t.index "lower(title)", unique: true, name: "index_videos_on_title"
    end
  end
end
