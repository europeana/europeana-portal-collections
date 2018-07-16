# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  describe 'concerns' do
    subject { described_class }
    it { is_expected.to include(Catalog) }
  end
end
