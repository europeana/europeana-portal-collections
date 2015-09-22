RSpec.describe SettingsController do
  it 'should use the styleguide' do
    expect(described_class).to include(Europeana::Styleguide)
  end

  describe 'GET #language' do
    before { get :language }
    it 'responds with 200 status' do
      expect(response.status).to eq(200)
    end
    it 'renders the language settings Mustache template' do
      expect(response).to render_template('settings/language')
    end
  end

  describe 'PUT #language' do
    context 'with locale param' do
      context 'when locale is available' do
        it 'updates locale in session' do
          session[:locale] = :en
          expect { put :language, locale: :nl }.to change { session[:locale] }.from(:en).to(:nl)
        end
        it 'sets flash notice' do
          put :language, locale: :nl
          expect(controller).to set_flash[:notice].now
        end
        context 'when format is html' do
          before { put :language, locale: :nl }
          it 'responds with 200 status' do
            expect(response.status).to eq(200)
          end
          it 'renders the language settings Mustache template' do
            expect(response).to render_template('settings/language')
          end
        end
        context 'when format is json' do
          before { put :language, locale: :nl, format: 'json' }
          let(:response_body) { JSON.parse(response.body) }

          it 'responds with 200 status' do
            expect(response.status).to eq(200)
          end
          it 'renders JSON' do
            expect { response_body }.not_to raise_error
          end
          it 'includes refresh: true' do
            expect(response_body['refresh']).to be true
          end
          it 'includes success: true' do
            expect(response_body['success']).to be true
          end
          it 'includes message' do
            expect(response_body['message']).not_to be_blank
          end
        end
      end

      context 'when locale is unavailable' do
        it 'does not change locale in session' do
          session[:locale] = :en
          expect { put :language, locale: :abc }.not_to change { session[:locale] }
        end
        it 'sets flash alert' do
          put :language, locale: :abc
          expect(controller).to set_flash[:alert].now
        end
        context 'when format is html' do
          before { put :language, locale: :abc }
          it 'responds with 400 status' do
            expect(response.status).to eq(400)
          end
          it 'renders the language settings Mustache template' do
            expect(response).to render_template('settings/language')
          end
        end
        context 'when format is json' do
          before { put :language, locale: :abc, format: 'json' }
          let(:response_body) { JSON.parse(response.body) }

          it 'responds with 400 status' do
            expect(response.status).to eq(400)
          end
          it 'renders JSON' do
            expect { response_body }.not_to raise_error
          end
          it 'includes refresh: false' do
            expect(response_body['refresh']).to be false
          end
          it 'includes success: false' do
            expect(response_body['success']).to be false
          end
          it 'includes message' do
            expect(response_body['message']).not_to be_blank
          end
        end
      end
    end

    context 'without locale param' do
      it 'does not change locale in session' do
        session[:locale] = :en
        expect { put :language }.not_to change { session[:locale] }
      end
      it 'sets flash notice' do
        put :language
        expect(controller).to set_flash[:notice].now
      end
      context 'when format is html' do
        before { put :language }
        it 'responds with 200 status' do
          expect(response.status).to eq(200)
        end
        it 'renders the language settings Mustache template' do
          expect(response).to render_template('settings/language')
        end
      end
      context 'when format is json' do
        before { put :language, format: 'json' }
        let(:response_body) { JSON.parse(response.body) }

        it 'responds with 200 status' do
          expect(response.status).to eq(200)
        end
        it 'renders JSON' do
          expect { response_body }.not_to raise_error
        end
        it 'includes refresh: false' do
          expect(response_body['refresh']).to be false
        end
        it 'includes success: true' do
          expect(response_body['success']).to be true
        end
        it 'includes message' do
          expect(response_body['message']).not_to be_blank
        end
      end
    end
  end
end
