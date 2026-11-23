class CreateComments < ActiveRecord::Migration[7.0]
  def change

    create_table :comments do |t|
      t.references :visitor, 		    null: false, foreign_key: true
      t.string :commentable_type,	  null: false, default: ""
      t.integer :commentable_id
      t.text :message
      t.string :status, 			      null: false, default: 'revision', comment: "revision|approved|rejected"

      t.timestamps
    end

  end

end
