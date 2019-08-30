namespace :plants do
  desc 'Send out reminder emails to users with plants that need care'
  task send_reminders: :environment do
    ReminderJob.perform_now
  end
end
