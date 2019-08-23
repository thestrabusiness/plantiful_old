require 'rails_helper'

RSpec.feature 'User can view a list of plants', type: :feature do
  it 'user can see a list of plant names' do
    skip
    plant1 = Plant.create(name: 'name')
    plant2 = Plant.create(name: 'other plant')
    visit plants_path
    expect(page).to have_content plant1.name
    expect(page).to have_content plant2.name
  end

  it 'user can see when a plant was last watered' do
    skip
    plant = Plant.create(name: 'name')
    plant.waterings.create

    visit plants_path

    expect(page).to have_content plant.last_watering_date
  end
end
