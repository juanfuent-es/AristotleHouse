class CreatePages < ActiveRecord::Migration[7.0]

  def change
    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')
    create_table :pages, id: :uuid do |t|
      t.string :lang,            null: false, default: "es"
      t.string :slug,            null: false, default: ""
      t.string :category,        null: false, default: "", comment: "Static | Blog | Article | Tutorial | Course | Workshop"

      # OG_metadata
      t.string :title,           null: false, default: ""
      t.text :content
      t.string :keywords,        default: ""

      t.string :og_type,         null: false, default: "website", comment: "audio|video|website"
      t.string :og_title,        null: false, default: ""
      t.string :og_image,        default: ""
      t.string :og_description,  null: false, default: ""

      t.boolean :restricted,     default: false, comment: "For static pages. e.g. Home, About, Contact, ..."

      # t.references :og,          type: :uuid
      t.references :author,      foreign_key: { to_table: :users }, type: :uuid
      t.references :versionable, polymorphic: true, type: :uuid, comment: "For languages versions"
      
      t.timestamps
    end

    create_table :blocks, id: :uuid do |t|
      t.references :page,     null: false, foreign_key: true, type: :uuid
      t.integer :number,      null: false, default: 0
      t.string :category,     null: false, default: "text", :limit => 10, comment: "text | css | js | html | glsl"
      t.string :title,        null: false, default: "", :limit => 70, comment: ""
      t.text :content
    end

  end

end