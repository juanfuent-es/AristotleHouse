# One table for projects and the fixed pages of the site. The columns are what visitors
# see; `draft_content` is what the editor is working on.
class CreatePages < ActiveRecord::Migration[8.1]
  def change
    create_table :pages, id: :uuid do |t|
      t.string :category, null: false, comment: "project | static | web-lab"
      t.string :slug, null: false, index: { unique: true }
      t.string :title, null: false, limit: 160
      t.string :description, null: false, default: "", limit: 300
      t.text :content, null: false, default: ""
      t.jsonb :facts, null: false, default: {}, comment: "client, location, year, scope"
      t.references :cover_image, type: :uuid, foreign_key: { to_table: :images }
      t.references :author, type: :uuid, foreign_key: { to_table: :users }

      t.string :publication_state, null: false, default: "draft"
      t.jsonb :draft_content
      t.integer :lock_version, null: false, default: 0
      t.datetime :published_at
      t.datetime :archived_at

      t.boolean :featured_on_home, null: false, default: false
      t.integer :home_position, null: false, default: 0

      # Media placed in the published text, so the library knows what is in use.
      t.uuid :image_ids, array: true, null: false, default: []
      t.uuid :video_ids, array: true, null: false, default: []
      t.timestamps

      t.index [:category, :publication_state]
      t.index :image_ids, using: :gin
      t.index :video_ids, using: :gin
      t.check_constraint "publication_state IN ('draft', 'published')", name: "page_publication_state"
    end
  end
end
