# Plantiful

Plantiful is an application that will let you track your plants health and watering schedule.

# Dependencies

* Ruby 2.6.5
* Rails 5.2.3
* Elm 0.19
* Postgres

# Running Locally

Clone the repo and `bundle install` in the root directory

`rails db:create && rails db:seed`

`yarn install` to setup webpack dependencies

`foreman start -f Procfile.dev` to run rails server and webpack-dev-server together

Visit `localhost:3000` to see the application
