class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :twitter_uid
      t.string :token
      t.string :secret

      t.timestamps
    end

    create_table :schedules do |t|
      t.references :users
      t.datetime :run_at

      t.timestamps
    end
  end
end


# Users.includes(:schedules).where(run_at: Time.now.hour).each do
#   user.update_profile_image
# end
