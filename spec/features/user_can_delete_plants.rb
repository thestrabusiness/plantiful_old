require 'rails_helper'

RSpec.feature 'User can delete plants' do
  it 'removes the plant from the plant list' do
    plant = create(:plant, name: 'Planthony')

    visit plant_path(plant, plant.user)
    click_on 'Delete'

    expect(page).to have_path('/plants')
    expect(page).to_not have_content(plant.name)
  end
end
