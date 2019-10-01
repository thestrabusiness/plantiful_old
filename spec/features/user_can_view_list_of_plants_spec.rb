require 'rails_helper'

RSpec.feature 'User can view a list of plants' do
  it 'user can see a list of plant names' do
    user = create(:user)
    plant1 = create(:plant, name: 'plant', user: user)
    plant2 = create(:plant, name: 'other plant', user: user)

    visit plants_path(user)
    expect(page).to have_content plant1.name
    expect(page).to have_content plant2.name
  end

  it 'user can see when a plant was last watered' do
    user = create(:user)
    plant = create(:plant, name: 'plant', user: user)
    plant.waterings.create

    visit plants_path(user)

    expect(page).to have_content 'Today'
  end
end
