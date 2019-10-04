require 'rails_helper'

RSpec.feature 'User can edit plants' do
  it 'updates the changed attributes' do
    plant = create(:plant,
                   name: 'Planthony',
                   check_frequency_scalar: 3,
                   check_frequency_unit: 'week')

    visit plant_path(plant, plant.user)
    click_on 'Edit'

    fill_in 'Name', with: 'my cool plant'
    within('label#check_frequency') do
      fill_in 'check_frequency_scalar', with: 1
      select 'Day', from: 'check_frequency_unit'
    end
    click_button 'Submit'

    expect(page).to have_current_path "/plants/#{plant.id}"
    plant.reload
    expect(plant.name).to eq 'my cool plant'
    expect(plant.check_frequency_unit).to eq 'day'
    expect(plant.check_frequency_scalar).to eq 1
  end
end

