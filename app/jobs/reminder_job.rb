class ReminderJob < ApplicationJob
  def perform
    User.find_each do |user|
      ReminderMailer
        .with(user: user)
        .remind
        .deliver_now
    end
  end
end
