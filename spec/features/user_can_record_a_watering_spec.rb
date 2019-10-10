require 'rails_helper'

RSpec.feature 'User can record when a plant is checked on' do
  it 'Adds a new check-in record for the given plant' do
    plant = create(:plant)

    visit garden_path(plant.garden, plant.added_by)
    click_on 'Check In'
    within('.modal__content--large') do
      check 'Watered'
      check 'Fertilized'
      fill_in 'Notes', with: 'Some notes'
    end
    click_on 'Submit'

    expect(page).to have_content 'Today'
    expect(page).to_not have_selector '.modal__content-large'
    plant = Plant.first
    check_in = plant.check_ins.take
    expect(plant.check_ins.count).to eq 1
    expect(check_in.watered).to be true
    expect(check_in.fertilized).to be true
    expect(check_in.notes).to eq 'Some notes'
  end
end
