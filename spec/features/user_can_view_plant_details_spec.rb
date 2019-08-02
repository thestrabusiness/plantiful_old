RSpec.feature 'User can view plant details' do
  it 'user can see the plants details' do
    skip
    plant = Plant.create(
      name: 'Planthony',
      botanical_name: 'Planthonius Moffa'
    )

    visit plant_path(plant)

    expect(page).to have_content plant.name
    expect(page).to have_content plant.botanical_name
  end

  it 'user can see the last 5 waterings' do
    skip
    plant = Plant.create(
      name: 'Planthony',
      botanical_name: 'Planthonius Moffa'
    )

    5.times { plant.waterings.create! }

    visit plant_path(plant)

    expect(page).to have_selector('.watering', count: 5)
  end
end
