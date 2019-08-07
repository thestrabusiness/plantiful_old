RSpec.describe 'Plant care event request', type: :request do
  describe 'POST plants/:id/plant_care_events' do
    context 'when a user is signed in' do
      it 'creates a watering for the given plant' do
        plant = create(:plant, name: 'Planty')
        api_sign_in(plant.user)

        post api_plant_plant_care_events_path(plant), params: { kind: 'watering'}

        result = response_json

        expect(plant.waterings.count).to eq 1
        expect(result[:name]).to eq 'Planty'
        expect(response.code).to eq '201'
      end
    end

    context 'when a user is not signed in' do
      it 'returns a 401 - Unauthorized' do
        plant = create(:plant)

        post api_plant_plant_care_events_path(plant)

        expect(response.code).to eq '401'
      end
    end
  end
end
