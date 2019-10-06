require 'rails_helper'

RSpec.feature 'User can view plant details' do
  it 'user can see the plants details' do
    plant = create(:plant, name: 'Planthony')
    create(:check_in, :watered, plant: plant, performed_by: plant.added_by)

    visit plant_path(plant, plant.added_by)

    expect(page).to have_content plant.name
    expect(page).to have_content 'Watered: Yes'
    expect(page).to have_content 'Fertilized: No'
  end

  it 'user can see the last 5 check-ins' do
    plant = create(:plant, :with_waterings, name: 'Planthony')

    visit plant_path(plant, plant.added_by)

    expect(page).to have_selector('.check_in__item', count: 5)
  end
end
