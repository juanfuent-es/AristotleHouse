class CreateTags < ActiveRecord::Migration[8.1]
  def change
    create_table :tags do |t|
      t.string :name, null: false, limit: 20, index: { unique: true }
    end

    create_table :taggings do |t|
      t.references :page, type: :uuid, null: false, foreign_key: true, index: false
      t.references :tag, null: false, foreign_key: true
      t.index [:page_id, :tag_id], unique: true
    end
  end
end
