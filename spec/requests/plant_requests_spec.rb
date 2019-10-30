require 'rails_helper'
require 'base64'

RSpec.describe 'Plant requests', type: :request do
  describe 'GET /api/plants' do
    context 'when a user is signed in' do
      context 'and the user has plants' do
        it 'returns a list of the users plants' do
          user = create(:user, :with_plants, number: 3)
          _other_plants = create_list(:plant, 3)

          get api_garden_plants_path(user.gardens.first),
              headers: auth_header(user)

          api_response = response_json
          returned_ids = api_response.collect { |result| result[:id] }

          expect(returned_ids.size).to eq 3
          expect(returned_ids).to match_array user.plants.pluck(:id)
        end
      end

      context 'and the user does not have plants' do
        it 'returns an empty list' do
          user = create(:user)
          _other_plants = create_list(:plant, 3)

          get api_garden_plants_path(user.gardens.first),
              headers: auth_header(user)

          result = response_json
          expect(result.size).to eq 0
        end
      end
    end

    context 'when no user is signed in' do
      it 'returns a 401 - Unauthorized' do
        user = create(:user)
        get api_garden_plants_path(user.gardens.first)
        expect(response.code).to eq '401'
      end
    end
  end

  describe 'POST /api/plants' do
    context 'with valid input' do
      it 'returns the created plant in the users garden' do
        user = create(:user)
        garden = user.gardens.first
        plant_params = { plant:
          { name: 'Bobby',
            check_frequency_scalar: 1,
            check_frequency_unit: 'week' } }

        post api_garden_plants_path(garden),
             params: plant_params,
             headers: auth_header(user)

        result = response_json

        expect(result[:name]).to eq plant_params[:plant][:name]
        expect(result[:check_frequency_unit])
          .to eq plant_params[:plant][:check_frequency_unit]
        expect(result[:check_frequency_scalar])
          .to eq plant_params[:plant][:check_frequency_scalar]
        expect(result[:garden_id]).to eq garden.id
      end
    end

    context 'with an invalid input' do
      it 'returns a 422 - Unprocessable Entity' do
        user = create(:user)
        plant_params = { plant:
          { name: nil,
            check_frequency_scalar: nil,
            check_frequency_unit: nil } }

        post api_garden_plants_path(user.gardens.first),
             params: plant_params,
             headers: auth_header(user)

        result = response_json

        expect(response.code).to eq '422'
        expect(result.keys)
          .to match_array %i[name check_frequency_scalar check_frequency_unit]
      end
    end
  end

  describe 'POST /api/plants/:id/avatar' do
    it 'attaches a new avatar to the plant' do
      plant = create(:plant)
      image_path = Rails.root.join('spec', 'fixtures', 'plant.jpg')
      base64_avatar =
        'data:image/jpg;base64,' + Base64.strict_encode64(File.read(image_path))

      expect {
        post_avatar(plant,
                    base64_avatar,
                    headers: auth_header(plant.added_by))
      }.to change { ActiveStorage::Blob.count }.from(0).to(1)

      result = response_json
      expect(result[:avatar]).to be
    end
  end

  describe 'DELETE /api/plants/:id' do
    it 'destroys the plant with the given ID' do
      plant = create(:plant)

      expect {
        delete api_plant_path(plant),
               headers: auth_header(plant.added_by)
      } .to change { Plant.count }.from(1).to(0)
      expect(response.status).to eq 200
    end
  end

  describe 'PUT /api/plants/:id' do
    context 'with valid input' do
      it 'returns the created plant' do
        plant = create(:plant,
                       name: 'Planthony',
                       check_frequency_scalar: 3,
                       check_frequency_unit: 'week')
        plant_params = { plant:
          { name: 'Bobby',
            check_frequency_scalar: 1,
            check_frequency_unit: 'day' } }

        put api_plant_path(plant.id),
            params: plant_params,
            headers: auth_header(plant.added_by)

        result = response_json

        expect(result[:name]).to eq plant_params[:plant][:name]
        expect(result[:check_frequency_unit]).to eq plant_params[:plant][:check_frequency_unit]
        expect(result[:check_frequency_scalar]).to eq plant_params[:plant][:check_frequency_scalar]
      end
    end

    context 'with an invalid input' do
      it 'returns a 422 - Unprocessable Entity' do
        plant = create(:plant,
                       name: 'Planthony',
                       check_frequency_scalar: 3,
                       check_frequency_unit: 'week')
        plant_params = { plant:
          { name: nil,
            check_frequency_scalar: nil,
            check_frequency_unit: nil } }

        put api_plant_path(plant.id),
            params: plant_params,
            headers: auth_header(plant.added_by)

        result = response_json

        expect(response.code).to eq '422'
        expect(result.keys).to match_array %i[name check_frequency_scalar check_frequency_unit]
      end
    end

    context 'with a valid input' do
      it 'updates the plant with the given attributes' do

      end
    end
  end

  def post_avatar(plant, avatar, headers:)
    post avatar_api_plant_path(plant),
         params: { plant: { avatar: avatar } },
         headers: headers
  end
end
