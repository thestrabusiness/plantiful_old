require 'rails_helper'

describe ReminderMailer do
  it 'sends an email if the user has active plants that need care' do
    user = create(:user)
    plant_needs_care = create(:plant, :with_avatar, added_by: user)
    _check_in = create(:check_in,
                       created_at: 7.days.ago,
                       plant: plant_needs_care,
                       performed_by: user)

    expect {
      ReminderMailer.with(user: user).remind.deliver_now
    }.to change { ActionMailer::Base.deliveries.length }.from(0).to(1)
  end

  it 'does not send an email if the user does not have plants that need care' do
    user = create(:user)
    _plant_needs_care = create(:plant, :with_avatar, added_by: user)

    expect {
      ReminderMailer.with(user: user).remind.deliver_now
    }.not_to change { ActionMailer::Base.deliveries.length }.from(0)
  end
end
