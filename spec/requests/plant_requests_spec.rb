RSpec.describe 'Plant requests', type: :request do
  describe 'GET /api/plants' do
    context 'when a user is signed in' do
      context 'and the user has plants' do
        it 'returns a list of the users plants' do
          user = create(:user, :with_plants, number: 3)
          _other_plants = create_list(:plant, 3)
          api_sign_in(user)

          get api_plants_path

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
          api_sign_in(user)

          get api_plants_path

          result = response_json
          expect(result.size).to eq 0
        end
      end
    end

    context 'when no user is signed in' do
      it 'returns a 401 - Unauthorized' do
        get '/api/plants'
        expect(response.code).to eq '401'
      end
    end
  end

  describe 'POST /api/plants' do
    context 'with valid input' do
      it 'returns the created plant' do
        user = create(:user)
        plant_params = { plant:
          { name: 'Bobby',
            check_frequency_scalar: 1,
            check_frequency_unit: 'week' } }

        api_sign_in(user)
        post api_plants_path, params: plant_params

        result = response_json

        expect(result[:name]).to eq 'Bobby'
        expect(result[:last_watering_date]).to be nil
        expect(result[:next_check_date]).to eq I18n.l(Time.current, format: :month_day_year)
      end
    end

    context 'with an invalid input' do
      it 'returns a 422 - Unprocessable Entity' do
        user = create(:user)
        plant_params = { plant:
          { name: nil,
            check_frequency_scalar: nil,
            check_frequency_unit: nil } }

        api_sign_in(user)
        post api_plants_path, params: plant_params

        result = response_json

        expect(response.code).to eq '422'
        expect(result.keys).to match_array %i[name check_frequency_scalar check_frequency_unit]
      end
    end
  end
end
