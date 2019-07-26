RSpec.describe 'Session requests', type: :request do
  describe 'POST /api/sessions' do
    context 'with the required fields' do
      context 'that match an existing user' do
        it 'returns the user and status 200' do
          user_params = { id: 100, first_name: 'Uncle', last_name: 'Tony', email: 'uncle@tony.com', password: 'password' }
          User.create(user_params)

          session_params = { user: { email: user_params[:email], password: user_params[:password] } }
          post '/api/sessions', params: session_params

          user_response = JSON.parse(response.body)

          expect(user_response['id']).to eq user_params[:id]
          expect(user_response['first_name']).to eq user_params[:first_name]
          expect(user_response['last_name']).to eq user_params[:last_name]
          expect(user_response['email']).to eq user_params[:email]
          expect(user_response['remember_token']).to be
          expect(response.code).to eq '200'
        end
      end

      context 'that don\'t match an existing user' do
        it 'returns a 401' do
          user_params = { first_name: 'Uncle', last_name: 'Tony', email: 'uncle@tony.com', password: 'password' }
          User.create(user_params)

          session_params = { user: { email: 'somethingelse@email.com', password: 'fake' } }
          post '/api/sessions', params: session_params

          expect(response.code).to eq '401'
        end
      end
    end

    describe 'DELETE api/sign_out' do
      it 'resets the users remember_token and returns a 200' do
        user_params = { id: 100, first_name: 'Uncle', last_name: 'Tony', email: 'uncle@tony.com', password: 'password' }
        user = User.create(user_params)

        session_params = { user: { email: user_params[:email], password: user_params[:password] } }
        post '/api/sessions', params: session_params

        remember_token = user.reload.remember_token

        delete '/api/sign_out'
        expect(user.reload.remember_token).to_not eq remember_token
      end
    end
  end
end