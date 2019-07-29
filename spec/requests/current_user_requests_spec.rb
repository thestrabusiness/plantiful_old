RSpec.describe 'Current user requests', type: :request do
  describe 'GET /api/current_user' do
    context 'when a user is logged in' do
      it 'returns the user' do
        user = create(:user)
        api_sign_in(user)

        get api_current_user_path

        user_response = response_json

        expect(user_response[:id]).to eq user.id
        expect(user_response[:first_name]).to eq user.first_name
        expect(user_response[:last_name]).to eq user.last_name
        expect(user_response[:email]).to eq user.email
        expect(user_response[:remember_token]).to eq user.remember_token
      end
    end

    context 'when a user is not logged in' do
      it 'returns an empty JSON response' do
        create(:user)

        get api_current_user_path

        user_response = response_json

        expect(user_response).to be nil
      end
    end
  end
end
