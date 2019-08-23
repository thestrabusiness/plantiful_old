require "rails_helper"

RSpec.describe Plant do
  describe '.need_care' do
    it 'returns plants who are on or past the last scheduled care time' do
      doesnt_need_care = create(:plant, :with_weekly_check, name: 'not included')
      create(:watering, plant: doesnt_need_care, happened_at: 6.days.ago)

      needs_care1 = create(:plant, :with_weekly_check, name: 'included1')
      create(:watering, plant: needs_care1, happened_at: 7.days.ago - 1.second)

      needs_care2 = create(:plant, :with_weekly_check, name: 'included2')
      create(:watering, plant: needs_care2, happened_at: 8.days.ago)

      expect(Plant.need_care.pluck(:name)).to match_array(%w[included1 included2])
    end
  end

  describe '#needs_care?' do
    context 'on the day a plant needs care' do
      it 'returns true' do
        plant = create(:plant, :with_weekly_check)
        create(:watering, plant: plant, happened_at: 7.days.ago)

        expect(plant.needs_care?).to eq true
      end
    end

    context 'on the day after the last scheduled care time' do
      it 'returns true' do
        plant = create(:plant, :with_weekly_check)
        create(:watering, plant: plant, happened_at: 8.days.ago)

        expect(plant.needs_care?).to eq true
      end
    end

    context 'on the day before the next scheduled care time' do
      it 'returns false' do
        plant = create(:plant, :with_weekly_check)
        create(:watering, plant: plant, happened_at: 6.days.ago)

        expect(plant.needs_care?).to eq false
      end
    end
  end

  describe '#next_watering' do
    context 'when the plant has at least one watering' do
      context 'and no checks' do
        it 'returns the last watering\'s date plus the check frequency' do
          watering_date = 1.day.ago
          expected_next_check = watering_date + 1.week

          plant = create(:plant, :with_weekly_check)
          create(:watering, plant: plant, happened_at: watering_date)

          expect(plant.next_check_date).to eq expected_next_check.strftime('%m/%d/%Y')
        end
      end

      context 'and a check that is less recent than the watering' do
        it 'returns the last watering\'s date plus the check frequency' do
          watering_date = 1.day.ago
          check_date = 3.day.ago
          expected_next_check = watering_date + 1.week

          plant = create(:plant, :with_weekly_check)
          create(:watering, plant: plant, happened_at: watering_date)
          create(:check, plant: plant, happened_at: check_date)

          expect(plant.next_check_date).to eq expected_next_check.strftime('%m/%d/%Y')
        end
      end

      context 'and a check that is more recent than the watering' do
        it 'returns the check\'s date plus the check frequency' do
          watering_date = 3.day.ago
          check_date = 1.day.ago
          expected_next_check = check_date + 1.week

          plant = create(:plant, :with_weekly_check)
          create(:watering, plant: plant, happened_at: watering_date)
          create(:check, plant: plant, happened_at: check_date)

          expect(plant.next_check_date).to eq expected_next_check.strftime('%m/%d/%Y')
        end
      end
    end

    context 'when the plant has at least one check and no waterings' do
      it 'returns the check\'s date plus the check frequency' do
        check_date = 1.day.ago
        expected_next_check = check_date + 1.week

        plant = create(:plant, :with_weekly_check)
        create(:check, plant: plant, happened_at: check_date)

        expect(plant.next_check_date).to eq expected_next_check.strftime('%m/%d/%Y')
      end
    end

    context 'when the plant does not have any waterings or checks' do
      it 'returns the current time' do
        Timecop.freeze do
          plant = create(:plant, :with_weekly_check)

          expect(plant.next_check_date).to eq Time.current.strftime('%m/%d/%Y')
        end
      end
    end
  end
end
