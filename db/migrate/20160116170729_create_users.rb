class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :twitter_uid, null: false
      t.string :token, null: false
      t.string :secret, null: false

      t.timestamps null: false
    end
    add_index :users, :twitter_uid, unique: true

    create_table :schedules do |t|
      t.references :user, index: true, null: false
      t.integer :hours, null: false

      t.timestamps null: false
    end
  end
end
