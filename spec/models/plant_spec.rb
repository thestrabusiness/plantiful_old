require "rails_helper"

RSpec.describe Plant do
  describe '#next_watering' do
    around(:each) do |example|
      Timecop.freeze do
        example.run
      end
    end

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
