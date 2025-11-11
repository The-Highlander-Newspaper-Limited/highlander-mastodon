# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/api/v1/statuses' do
  context 'with an oauth token' do
    let(:user)  { Fabricate(:user) }
    let(:client_app) { Fabricate(:application, name: 'Test app', website: 'http://testapp.com') }
    let(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id, application: client_app, scopes: scopes) }
    let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

    describe 'POST /api/v1/statuses' do
      subject do
        post '/api/v1/statuses', headers: headers, params: params
      end

      let(:scopes) { 'write:statuses' }
      let(:params) { { status: 'Hello world' } }

      it_behaves_like 'forbidden for wrong scope', 'read read:statuses'

      context 'when user role forbids posting' do
        let(:role_reader) { Fabricate(:user_role, permissions: UserRole::Flags::DEFAULT) }
        let(:user) { Fabricate(:user, role: role_reader) }

        it 'returns forbidden' do
          subject

          expect(response).to have_http_status(403).or have_http_status(403)
          expect(response.parsed_body[:error]).to be_present
        end
      end

      context 'when user role allows posting' do
        let(:role_poster) { Fabricate(:user_role, permissions: UserRole::FLAGS[:create_statuses]) }
        let(:user) { Fabricate(:user, role: role_poster) }

        it 'creates the post successfully' do
          expect { subject }.to change { user.account.statuses.count }.by(1)

          expect(response).to have_http_status(200)
          expect(response.parsed_body[:content]).to include('Hello world')
        end
      end

      context 'when replying' do
        let!(:parent_status) { Fabricate(:status) }
        let(:params) { { status: 'Replying', in_reply_to_id: parent_status.id } }

        context 'when user role forbids replying' do
          let(:role_reader) { Fabricate(:user_role, permissions: UserRole::Flags::DEFAULT) }
          let(:user) { Fabricate(:user, role: role_reader) }

          it 'returns forbidden when trying to reply' do
            subject

            expect(response).to have_http_status(403)
            expect(response.parsed_body[:error]).to be_present
          end
        end

        context 'when user role allows posting but forbids replying' do
          let(:role_poster_no_reply) { Fabricate(:user_role, permissions: UserRole::FLAGS[:create_statuses]) }
          let(:user) { Fabricate(:user, role: role_poster_no_reply) }

          it 'returns forbidden when trying to reply' do
            subject

            expect(response).to have_http_status(403)
            expect(response.parsed_body[:error]).to be_present
          end
        end

        context 'when user role allows posting and replying' do
          let(:role_replier) { Fabricate(:user_role, permissions: UserRole::FLAGS[:create_statuses] | UserRole::FLAGS[:reply_to_statuses]) }
          let(:user) { Fabricate(:user, role: role_replier) }

          it 'creates the reply successfully' do
            expect { subject }.to change { user.account.statuses.count }.by(1)

            expect(response).to have_http_status(200)
            expect(response.parsed_body[:content]).to include('Replying')
          end
        end
      end
    end
  end
end
