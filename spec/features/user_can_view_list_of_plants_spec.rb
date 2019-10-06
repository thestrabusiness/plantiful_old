require 'rails_helper'

RSpec.feature 'User can view a list of plants' do
  it 'user can see a list of plant names' do
    garden = create(:garden)
    user = create(:user, garden: garden)
    plant1 = create(:plant, name: 'plant', garden: garden)
    plant2 = create(:plant, name: 'other plant', garden: garden)

    visit plants_path(user)
    expect(page).to have_content plant1.name
    expect(page).to have_content plant2.name
  end

  it 'user can see when a plant was last watered' do
    garden = create(:garden)
    user = create(:user, garden: garden)
    plant = create(:plant, name: 'plant', garden: garden)
    plant.waterings.create(performed_by: user)

    visit plants_path(user)

    expect(page).to have_content 'Today'
  end

  it 'user can see when a plant is overdue for watering' do
    garden = create(:garden)
    user = create(:user, garden: garden)
    _plant_without_watering = create(:plant, name: 'plant', garden: garden)

    visit plants_path(user)

    expect(page).to have_selector '.plant__list-indicator'
  end
end
