RSpec.feature 'UserCanCreatePlants', type: :feature do
  it 'a user can create a new plant with a name and a botanical name' do
    visit root_path
    click_on 'New Plant'
    fill_in :plant_name, with: 'my cool plant'
    fill_in :plant_botanical_name, with: 'plantus coolicus'
    click_button 'Save Plant'

    expect(page).to have_content 'plant created!'
  end
end
