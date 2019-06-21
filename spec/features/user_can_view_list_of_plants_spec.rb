require 'rails_helper'

RSpec.feature "UserCanViewListOfPlants", type: :feature do
  it 'user can see a list of plant names' do
    plant1 = Plant.create(name: 'name')
    plant2 = Plant.create(name: 'other plant')
    visit plants_path
    expect(page).to have_content plant1.name
    expect(page).to have_content plant2.name
  end
end
