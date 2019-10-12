PLANT_1_IMAGE_PATH = Rails.root.join('spec', 'fixtures', 'plant_stock1.jpg')
PLANT_2_IMAGE_PATH = Rails.root.join('spec', 'fixtures', 'plant_stock2.jpg')
PLANT_3_IMAGE_PATH = Rails.root.join('spec', 'fixtures', 'plant_stock3.jpg')
PLANT_4_IMAGE_PATH = Rails.root.join('spec', 'fixtures', 'plant_stock4.jpg')

plant_image_paths = [
  PLANT_1_IMAGE_PATH,
  PLANT_2_IMAGE_PATH,
  PLANT_3_IMAGE_PATH,
  PLANT_4_IMAGE_PATH
]


uncle = User.create!(
  email: "uncletony@example.com",
  first_name: "Uncle",
  last_name: "Tony",
  password: "password",
)

auntie = User.create!(
  email: "auntietony@example.com",
  first_name: "Auntie",
  last_name: "Tony",
  password: "password",
)

users = [uncle, auntie]

uncle_garden = Garden.create!(name: uncle.default_garden_name,  owner: uncle)
uncle_garden.users << auntie

auntie_garden = Garden.create!(name: auntie.default_garden_name, owner: auntie)
auntie_garden.users << uncle

[uncle_garden, auntie_garden].each do |garden|
  12.times do |i|
    plant = Plant.create!(
      added_by: users.sample,
      botanical_name: "Newus Plantus #{i}",
      check_frequency_scalar: 1,
      check_frequency_unit: 'week',
      garden: garden,
      name: "Plant #{i}",
    )

    plant
      .avatar
      .attach(
        io: File.open(plant_image_paths.sample),
        filename: "plant#{i}.jpg"
    )
  end
end

Plant.find_each do |plant|
  rand(2..5).times do
    created_at = Array(1..9).sample.days.ago
    plant.check_ins.create!(
      created_at: created_at,
      fertilized: false,
      notes: BetterLorem.w(rand(15..25), true),
      performed_by: users.sample,
      watered: true,
    )
  end
end
