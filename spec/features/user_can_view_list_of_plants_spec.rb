require 'rails_helper'

RSpec.feature 'User can view a list of plants' do
  it 'user can see a list of plant names' do
    user = create(:user)
    garden = user.owned_gardens.first
    plant1 = create(:plant, name: 'plant', added_by: user, garden: garden)
    plant2 = create(:plant, name: 'other plant', added_by: user, garden: garden)

    visit garden_path(garden, user)
    expect(page).to have_content plant1.name
    expect(page).to have_content plant2.name
  end

  it 'user can see when a plant was last watered' do
    user = create(:user)
    garden = user.owned_gardens.first
    plant = create(:plant, name: 'plant', added_by: user, garden: garden)
    plant.waterings.create(performed_by: user)

    visit garden_path(garden, user)

    expect(page).to have_content 'Today'
  end

  it 'user can see when a plant is overdue for watering' do
    user = create(:user)
    garden = user.owned_gardens.first
    _plant_without_watering = create(:plant,
                                     name: 'plant',
                                     added_by: user,
                                     garden: garden)

    visit garden_path(garden, user)

    expect(page).to have_selector '.plant__list-indicator'
  end
end
