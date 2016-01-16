class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :twitter_uid
      t.string :token
      t.string :secret

      t.timestamps
    end

    create_table :schedules do |t|
      t.references :user
      t.integer :hours

      t.timestamps
    end
  end
end
