require 'rails_helper'

RSpec.feature 'User can create plants' do
  it 'a user can create a new plant with a name and check frequency' do
    garden = create(:garden)
    visit garden_path(garden, garden.owner)

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

  it 'uses "day" for the default value of check frequency unit' do
    garden = create(:garden)
    visit garden_path(garden, garden.owner)

    click_on 'Add New Plant'
    fill_in 'Name', with: 'my cool plant'
    within('label#check_frequency') do
      fill_in 'check_frequency_scalar', with: 1
    end
    click_button 'Submit'

    expect(page).to have_content 'my cool plant'
    plant = Plant.first
    expect(plant.check_frequency).to eq 1.day
  end

  it 'assigns the plant to the appropriate garden' do
    user = create(:user)
    _default_garden = user.owned_gardens.take
    other_garden = create(:garden, owner: user)

    visit garden_path(other_garden, user)

    click_on 'Add New Plant'
    fill_in 'Name', with: 'my cool plant'
    within('label#check_frequency') do
      fill_in 'check_frequency_scalar', with: 1
    end
    click_button 'Submit'

    expect(page).to have_content 'my cool plant'
    plant = Plant.first
    expect(plant.garden_id).to eq other_garden.id
  end
end
