RSpec.describe 'User requests', type: :request do
  describe 'POST /api/users' do
    context 'with the required fields' do
      it 'returns the created user' do
        user_params = { user: { first_name: 'Uncle', last_name: 'Tony', email: 'uncle@tony.com', password: 'password'} }
        post '/api/users', params: user_params

        user_response = JSON.parse(response.body)

        expect(user_response['id']).to be
        expect(user_response['first_name']).to eq 'Uncle'
        expect(user_response['last_name']).to eq 'Tony'
        expect(user_response['email']).to eq 'uncle@tony.com'
        expect(user_response['remember_token']).to be
      end
    end
  end
end