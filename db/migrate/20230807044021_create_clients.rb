class CreateClients < ActiveRecord::Migration[7.0]
  def change
    create_table :clients do |t|
      t.string :name
      t.string :description
      t.string :url
      t.string :email
      t.string :logo
      t.references :country, null: false, foreign_key: true
      t.text :address

      t.timestamps
    end
  end
end
