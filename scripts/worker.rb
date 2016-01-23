require 'dotenv'
Dotenv.load

require_relative '../yryr_icon'

User.includes(:schedule).where(schedules: {hours: Time.now.hour}).map(&:update_icon_randomly)
