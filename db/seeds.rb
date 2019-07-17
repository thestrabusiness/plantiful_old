user = User.create!(
  first_name: "Uncle",
  last_name: "Tony",
  email: "uncletony@example.com",
  password: "password"
)

12.times { |i| Plant.create!(user: user, name: "Plant #{i}", botanical_name: "Newus Plantus #{i}") }
