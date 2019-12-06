require 'rails_helper'

describe User do
  describe 'validations' do
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:password) }
  end

  describe 'associations' do
    describe 'active_plants' do
      it 'should only return plants that have not been deleted' do
        user = create(:user)
        active_plant = create(:plant, added_by: user)
        deleted_plant = create(:plant, :deleted, added_by: user)

        active_plants = user.active_plants
        expect(active_plants).to_not include deleted_plant
        expect(active_plants).to include active_plant
      end
    end
  end
end
