class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    enable_extension "pgcrypto"

    create_table :users, id: :uuid do |t|
      t.string :role, null: false, default: "visitor"
      t.string :name, null: false, default: ""
      t.string :username, null: false, default: ""
      t.string :email, null: false, default: "", index: { unique: true }
      t.string :encrypted_password, null: false, default: ""
      t.boolean :banned, null: false, default: false
      t.datetime :remember_created_at
      t.timestamps
    end
  end
end
