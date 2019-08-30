require 'rails_helper'

RSpec.describe 'Check-in request', type: :request do
  describe 'POST plants/:id/check_ins' do
    context 'when a user is signed in' do
      context 'marks a plant watered' do
        it 'creates check-in with watered true for the given plant' do
          plant = create(:plant, name: 'Planty')
          api_sign_in(plant.user)

          json_post(api_plant_check_ins_path(plant),
                    params: { check_in: { watered: true, fertilized: false } })

          result = response_json

          expect(plant.check_ins.count).to eq 1
          expect(result[:plant][:id]).to eq plant.id
          expect(result[:watered]).to eq true
          expect(result[:fertilized]).to eq false
          expect(response.code).to eq '201'
        end
      end

      context 'marks a plant fertilized' do
        it 'creates a check-in with fertilized true for the given plant' do
          plant = create(:plant, name: 'Planty')
          api_sign_in(plant.user)

          json_post(api_plant_check_ins_path(plant),
                    params: { check_in: { watered: false, fertilized: true } })

          result = response_json

          expect(plant.check_ins.count).to eq 1
          expect(result[:plant][:id]).to eq plant.id
          expect(result[:watered]).to eq false
          expect(result[:fertilized]).to eq true
          expect(response.code).to eq '201'
        end
      end

      context 'adds notes to the check-in' do
        it 'creates a check-in with notes for the given plant' do
          plant = create(:plant, name: 'Planty')
          api_sign_in(plant.user)

          json_post(api_plant_check_ins_path(plant),
                    params: { check_in: { watered: false,
                                          fertilized: false,
                                          notes: 'here are some notes' } })

          result = response_json

          expect(plant.check_ins.count).to eq 1
          expect(result[:plant][:id]).to eq plant.id
          expect(result[:notes]).to eq 'here are some notes'
          expect(result[:watered]).to eq false
          expect(result[:fertilized]).to eq false
          expect(response.code).to eq '201'
        end
      end

      context 'with missing required data' do
        context 'such as a missing "watered" key' do
          it 'creates the check-in with watered false' do
            plant = create(:plant, name: 'Planty')
            api_sign_in(plant.user)

            json_post(api_plant_check_ins_path(plant),
                      params: { check_in: { watered: false,
                                            fertilized: false,
                                            notes: 'here are some notes' } })

            result = response_json
            expect(plant.check_ins.count).to eq 1
            expect(result[:watered]).to eq false
          end
        end
      end
    end

    context 'when a user is not signed in' do
      it 'returns a 401 - Unauthorized' do
        plant = create(:plant)

        post api_plant_check_ins_path(plant)

        expect(response.code).to eq '401'
      end
    end
  end
end
