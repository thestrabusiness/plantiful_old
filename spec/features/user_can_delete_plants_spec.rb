require 'rails_helper'

RSpec.feature 'User can delete plants' do
  it 'removes the plant from the plant list' do
    plant = create(:plant, name: 'Planthony')

    visit plant_path(plant, plant.added_by)
    delete_button = find('.trashcan')
    delete_button.click

    expect(page).to have_current_path('/plants')
    expect(page).to_not have_content(plant.name)
  end
end
