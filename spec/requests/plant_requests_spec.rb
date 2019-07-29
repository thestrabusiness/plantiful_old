RSpec.describe 'Plant requests', type: :request do
  describe 'get /api/plants' do
    context 'when a user is signed in' do
      context 'and the user has plants' do
        it 'returns a list of the users plants' do
          user = create(:user, :with_plants, number: 3)
          other_plants = create_list(:plant, 3)
          api_sign_in(user)

          get api_plants_path

          result = response_json
          returned_ids = result.collect { |result| result[:id] }

          expect(returned_ids.size).to eq 3
          expect(returned_ids).to match_array user.plants.pluck(:id)
        end
      end

      context 'and the user does not have plants' do
        it 'returns an empty list' do
          user = create(:user)
          other_plants = create_list(:plant, 3)
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
end
