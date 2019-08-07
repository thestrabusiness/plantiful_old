user = User.create!(
  first_name: "Uncle",
  last_name: "Tony",
  email: "uncletony@example.com",
  password: "password"
)

12.times do |i|
  Plant.create!(
    user: user,
    name: "Plant #{i}",
    botanical_name: "Newus Plantus #{i}",
    check_frequency_scalar: 1,
    check_frequency_unit: 'week'
  )
end

Plant.find_each do |plant|
  plant.plant_care_events.create!(
    kind: 'watering',
    happened_at: Array(1..9).sample.days.ago
  )
end
