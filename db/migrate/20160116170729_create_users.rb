class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :twitter_uid
      t.string :token
      t.string :secret

      t.timestamps
    end
    add_index :users, :twitter_uid, unique: true

    create_table :schedules do |t|
      t.references :user, index: true
      t.integer :hours

      t.timestamps
    end
  end
end
