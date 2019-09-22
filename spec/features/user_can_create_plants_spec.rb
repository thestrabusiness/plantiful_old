require 'rails_helper'

RSpec.feature 'UserCanCreatePlants', js: true do
  it 'a user can create a new plant with a name and check frequency' do
    user = create(:user)
    visit plants_path(user)

    click_on 'Add New Plant'
    fill_in 'Name', with: 'my cool plant'
    within('label#check_frequency') do
      fill_in 'check_frequency_scalar', with: 1
      select 'Week', from: 'check_frequency_unit'
    end
    click_button 'Submit'

    expect(page).to have_content 'my cool plant'
    plant = Plant.first
    expect(plant.check_frequency).to eq 1.week
  end
end
