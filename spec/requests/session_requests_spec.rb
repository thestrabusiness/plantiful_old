require 'rails_helper'

RSpec.describe 'Session requests', type: :request do
  describe 'POST /api/sessions' do
    context 'with the required fields' do
      context 'that match an existing user' do
        it 'returns the user and status 200' do
          user = create(:user)

          session_params = {
            user: {
              email: user.email,
              password: user.password
            }
          }
          post api_sessions_path, params: session_params

          user_response = response_json

          expect(user_response[:id]).to eq user.id
          expect(user_response[:first_name]).to eq user.first_name
          expect(user_response[:last_name]).to eq user.last_name
          expect(user_response[:email]).to eq user.email
          expect(response.code).to eq '200'
        end
      end

      context 'that don\'t match an existing user' do
        it 'returns a 401' do
          create(:user,
                 email: 'realemail@example.com',
                 password: 'realpassword')

          session_params = {
            user: {
              email: 'somethingelse@email.com',
              password: 'fake'
            }
          }
          post api_sessions_path, params: session_params

          expect(response.code).to eq '401'
        end
      end
    end

    describe 'DELETE api/sign_out' do
      context 'with a desktop session' do
        it 'resets the users remember_token and returns a 200' do
          user = create(:user)
          remember_token = user.remember_token
          mobile_token = user.mobile_api_token

          delete api_sign_out_path, headers: auth_header(user, 'desktop')

          expect(user.reload.remember_token).to_not eq remember_token
          expect(user.reload.mobile_api_token).to eq mobile_token
        end
      end

      context 'with a mobile session' do
        it 'resets the users mobile_api_token and returns a 200' do
          user = create(:user)
          remember_token = user.remember_token
          mobile_token = user.mobile_api_token

          delete api_sign_out_path, headers: auth_header(user, 'mobile')

          expect(user.reload.mobile_api_token).to_not eq mobile_token
          expect(user.reload.remember_token).to eq remember_token
        end
      end
    end
  end
end
