require 'dotenv'
Dotenv.load

require_relative '../yryr_icon'

User.includes(:schedule).where(schedules: {hours: Time.now.hour}).each do |user|
  puts "start updating. user_id: #{user.id}"

  begin
    user.update_icon_randomly
  rescue => e
    # to continue updating, skip the error
    puts "Scheduled update failed. user_id: #{user.id}"
    puts e.class, e.message
    puts e.backtrace.join("\n")
  end
end
