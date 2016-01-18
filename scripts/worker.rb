require_relative '../app'

User.includes(:schedule).where(schedules: {hours: Time.now.hour}).map(&:update_icon_randomly)
