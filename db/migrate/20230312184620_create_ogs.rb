class CreateOgs < ActiveRecord::Migration[7.0]
  def change
    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')
    create_table :ogs, id: :uuid do |t|
      t.string :category,     null: false, default: ''
      t.string :mime_type,    null: false, default: ''
      t.string :extension,    null: false, default: ''
      t.string :image,          default: ''
      t.string :video,        default: ''
      t.string :audio,        default: ''
      t.integer :width,       default: 0
      t.integer :height,      default: 0
    end
  end
end
