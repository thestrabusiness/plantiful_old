require 'rails_helper'

RSpec.describe NeedsCheckIn do
  describe '.plants' do
    it 'returns plants who are at or past the last scheduled care time' do
      doesnt_need_care = create(:plant, :with_weekly_check, name: 'not included')
      create(:check_in, plant: doesnt_need_care, created_at: 12.days.ago)
      create(:check_in, plant: doesnt_need_care, created_at: 5.days.ago)

      needs_care1 = create(:plant, :with_weekly_check, name: 'included1')
      create(:check_in, plant: needs_care1, created_at: 7.days.ago - 1.second)

      needs_care2 = create(:plant, :with_weekly_check, name: 'included2')
      create(:check_in, plant: needs_care2, created_at: 8.days.ago)

      plants_that_need_care_names = NeedsCheckIn.plants.pluck(:name)

      expect(plants_that_need_care_names).to match_array(%w[included1 included2])
    end
  end

  describe '.users' do
    it 'returns users whose plants are at or past the last scheduled care time' do
      doesnt_need_care = create(:plant, :with_weekly_check, name: 'not included')
      create(:check_in,
             plant: doesnt_need_care,
             created_at: 12.days.ago,
             performed_by: doesnt_need_care.added_by)
      create(:check_in,
             plant: doesnt_need_care,
             created_at: 5.days.ago,
             performed_by: doesnt_need_care.added_by)

      needs_care1 = create(:plant, :with_weekly_check, name: 'included1')
      create(:check_in,
             plant: needs_care1,
             created_at: 7.days.ago - 1.second,
             performed_by: needs_care1.added_by)

      needs_care2 = create(:plant, :with_weekly_check, name: 'included2')
      create(:check_in,
             plant: needs_care2,
             created_at: 8.days.ago,
             performed_by: needs_care2.added_by)

      user_last_names = NeedsCheckIn.users.pluck(:last_name)
      expected_user_last_names =
        [needs_care1.added_by.last_name, needs_care2.added_by.last_name]

      expect(user_last_names).to match_array(expected_user_last_names)
    end
  end
end
