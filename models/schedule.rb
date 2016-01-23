class Schedule < ActiveRecord::Base
  belongs_to :user

  validates :hours, presence: true, numericality: {greater_than_or_equal_to: 0, less_than: 24}
end
