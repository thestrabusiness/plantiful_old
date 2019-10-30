require 'rails_helper'

RSpec.describe 'Garden requests' do
  describe 'POST api/gardens' do
    context 'with a valid input' do
      it 'creates a new garden for the signed-in user' do
        user = create(:user)
        garden_name = 'A new garden'
        garden_params = { garden: { name: garden_name } }

        expect {
          post api_gardens_path,
               params: garden_params,
               headers: auth_header(user)
        }
          .to change { Garden.count }.by 1
      end

      it 'returns the new garden and status ok' do
        user = create(:user)
        garden_name = 'A new garden'
        garden_params = { garden: { name: garden_name } }

        post api_gardens_path,
             params: garden_params,
             headers: auth_header(user)

        result = response_json

        expect(result[:name]).to eq garden_name
        expect(result[:owner_id]).to eq user.id
        expect(response.code).to eq '200'
      end
    end

    context 'with an invalid input, such as missing name' do
      it 'does not create a new garden' do
        user = create(:user)
        original_garden_count = Garden.count
        garden_params = { garden: { name: '' } }

        expect {
          post api_gardens_path,
               params: garden_params,
               headers: auth_header(user)
        }
          .to_not change { Garden.count }.from original_garden_count
      end

      it 'returns the gardens errors and status 422' do
        user = create(:user)
        garden_params = { garden: { name: '' } }

        post api_gardens_path,
             params: garden_params,
             headers: auth_header(user)

        result = response_json

        expect(result[:name]).to be
        expect(response.code).to eq '422'
      end
    end

    context 'without an authenticated user' do
      it 'does not create a new garden' do
        user = create(:user)
        original_garden_count = Garden.count
        garden_params = { garden: { name: '' } }

        expect {
          post api_gardens_path,
               params: garden_params,
               headers: auth_header(user)
        }
          .to_not change { Garden.count }.from original_garden_count
      end

      it 'returns a 401' do
        _user = create(:user)
        garden_name = 'A new garden'
        garden_params = { garden: { name: garden_name } }

        post api_gardens_path, params: garden_params

        expect(response.code).to eq '401'
      end
    end
  end

  describe 'PUT api/gardens/:id' do
    context 'with a valid input' do
      it 'updates the garden' do
        user = create(:user)
        garden = user.owned_gardens.first
        original_name = garden.name
        new_name = 'A new name'
        garden_params = { garden: { name: new_name } }

        expect {
          put api_garden_path(garden),
              params: garden_params,
              headers: auth_header(user)
        }
          .to change { garden.reload.name }
          .from(original_name)
          .to(garden_params[:garden][:name])
      end

      it 'returns the updated garden and status ok' do
        user = create(:user)
        garden = user.owned_gardens.first
        new_name = 'A new name'
        garden_params = { garden: { name: new_name } }

        put api_garden_path(garden),
            params: garden_params,
            headers: auth_header(user)

        result = response_json

        expect(result[:name]).to eq new_name
        expect(response.code).to eq '200'
      end
    end

    context 'with an invalid input, such as missing name' do
      it 'does not update the garden' do
        user = create(:user)
        garden = user.owned_gardens.first
        garden_params = { garden: { name: '' } }

        expect {
          put api_garden_path(garden),
              params: garden_params,
              headers: auth_header(user)
        }
          .to_not change { garden.reload.name }
      end

      it 'returns the gardens errors and status 422' do
        user = create(:user)
        garden = user.owned_gardens.first
        garden_params = { garden: { name: '' } }

        put api_garden_path(garden),
            params: garden_params,
            headers: auth_header(user)

        result = response_json

        expect(result[:name]).to be
        expect(response.code).to eq '422'
      end
    end

    context 'without an authenticated user' do
      it 'does not update the garden' do
        user = create(:user)
        garden = user.owned_gardens.first
        original_garden_name = garden.name
        garden_params = { garden: { name: 'new name' } }

        expect { put api_garden_path(garden), params: garden_params }
          .to_not change { garden.reload.name }.from original_garden_name
      end

      it 'returns a 401' do
        user = create(:user)
        garden = user.owned_gardens.first
        garden_params = { garden: { name: 'new name' } }

        put api_garden_path(garden), params: garden_params

        expect(response.code).to eq '401'
      end
    end
  end

  describe 'DELETE api/gardens/:id' do
    it 'deletes the garden and returns status ok' do
      user = create(:user)
      original_garden_count = Garden.count
      garden = user.owned_gardens.first

      delete api_garden_path(garden), headers: auth_header(user)

      expect(response.code).to eq '200'
      expect(Garden.count).to eq original_garden_count - 1
    end

    context 'without an authenticated user' do
      it 'does not delete the garden' do
        user = create(:user)
        original_garden_count = Garden.count
        garden = user.owned_gardens.first

        expect { delete api_garden_path(garden) }
          .to_not change { Garden.count }
          .from(original_garden_count)
      end

      it 'returns a 401' do
        user = create(:user)
        garden = user.owned_gardens.first

        delete api_garden_path(garden)

        expect(response.code).to eq '401'
      end
    end
  end
end
