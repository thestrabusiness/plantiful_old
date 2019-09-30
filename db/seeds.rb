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

user = User.create!(
  first_name: "Uncle",
  last_name: "Tony",
  email: "uncletony@example.com",
  password: "password"
)

12.times do |i|
  plant = Plant.create!(
    user: user,
    name: "Plant #{i}",
    botanical_name: "Newus Plantus #{i}",
    check_frequency_scalar: 1,
    check_frequency_unit: 'week'
  )

  plant
    .avatar
    .attach(
      io: File.open(plant_image_paths.sample),
      filename: "plant#{i}.jpg"
  )
end

Plant.find_each do |plant|
  rand(2..5).times do
    created_at = Array(1..9).sample.days.ago
    plant.check_ins.create!(
      watered: true,
      fertilized: false,
      notes: BetterLorem.w(rand(15..25), true),
      created_at: created_at
    )
  end
end
