require 'rails_helper'

RSpec.describe Plant do
  describe 'validations' do
    it { should validate_presence_of(:added_by) }
    it { should validate_presence_of(:check_frequency_scalar) }
    it { should validate_numericality_of(:check_frequency_scalar) }
    it { should validate_presence_of(:check_frequency_unit) }
    it { should validate_inclusion_of(:check_frequency_unit).in_array Plant::FREQUENCY_UNITS }
    it { should validate_presence_of(:garden) }
    it { should validate_presence_of(:name) }
  end

  describe '#needs_care?' do
    context 'on the day a plant needs care' do
      it 'returns true' do
        plant = create(:plant, :with_weekly_check)
        create(:check_in, :watered, plant: plant, created_at: 7.days.ago)

        expect(plant.needs_care?).to eq true
      end
    end

    context 'on the day after the last scheduled care time' do
      it 'returns true' do
        plant = create(:plant, :with_weekly_check)
        create(:check_in, :watered, plant: plant, created_at: 8.days.ago)

        expect(plant.needs_care?).to eq true
      end
    end

    context 'on the day before the next scheduled care time' do
      it 'returns false' do
        plant = create(:plant, :with_weekly_check)
        create(:check_in, :watered, plant: plant, created_at: 6.days.ago)

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
          create(:check_in, :watered, plant: plant, created_at: watering_date)

          expect(plant.next_check_date).to eq expected_next_check.strftime('%m/%d/%Y')
        end
      end

      context 'and a check that is less recent than the watering' do
        it 'returns the last watering\'s date plus the check frequency' do
          watering_date = 1.day.ago
          check_date = 3.day.ago
          expected_next_check = watering_date + 1.week

          plant = create(:plant, :with_weekly_check)
          create(:check_in, :watered, plant: plant, created_at: watering_date)
          create(:check_in, plant: plant, created_at: check_date)

          expect(plant.next_check_date).to eq expected_next_check.strftime('%m/%d/%Y')
        end
      end

      context 'and a check that is more recent than the watering' do
        it 'returns the check\'s date plus the check frequency' do
          watering_date = 3.day.ago
          check_date = 1.day.ago
          expected_next_check = check_date + 1.week

          plant = create(:plant, :with_weekly_check)
          create(:check_in, :watered, plant: plant, created_at: watering_date)
          create(:check_in, plant: plant, created_at: check_date)

          expect(plant.next_check_date).to eq expected_next_check.strftime('%m/%d/%Y')
        end
      end
    end

    context 'when the plant has at least one check and no waterings' do
      it 'returns the check\'s date plus the check frequency' do
        check_date = 1.day.ago
        expected_next_check = check_date + 1.week

        plant = create(:plant, :with_weekly_check)
        create(:check_in, plant: plant, created_at: check_date)

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
