require 'rails_helper'

RSpec.feature 'User can record when a plant is watered' do
  it 'Adds a new watering event record for the given plant' do
    plant = Plant.create(name: 'test')

    visit plants_path
    click_on 'Water'

    expect(current_path).to eq plants_path
    expect(page).to have_content 'Plant watered!'
    expect(plant.waterings.count).to eq 1
  end
end
