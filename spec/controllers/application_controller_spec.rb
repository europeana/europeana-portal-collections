# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  describe 'concerns' do
    subject { described_class }
    it { is_expected.to include(Catalog) }
  end

  describe 'GET status' do
    it 'returns plain text status message' do
      get :status
      expect(response.status).to eq(200)
      expect(response.content_type).to eq('text/plain')
      expect(response.body).to eq('OK')
    end
  end
end
