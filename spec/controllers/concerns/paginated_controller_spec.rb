# frozen_string_literal: true

RSpec.describe PaginatedController do
  let(:controller_class) do
    Class.new(ApplicationController) do
      include PaginatedController
    end
  end

  let(:controller_params) { {} }

  subject { controller_class.new }

  before do
    allow(subject).to receive(:params) { controller_params }
  end

  describe '.pagination_per_default' do
    it 'defaults to 12' do
      expect(subject.class.pagination_per_default).to eq(12)
    end
  end

  describe '#pagination_page' do
    context 'with :page in params' do
      let(:controller_params) { { page: '77' } }

      it 'returns :page param as integer' do
        expect(subject.pagination_page).to eq(77)
      end
    end

    context 'without :page in params' do
      it 'returns 1' do
        expect(subject.pagination_page).to eq(1)
      end
    end
  end

  describe '#pagination_per' do
    context 'with :per_page in params' do
      let(:controller_params) { { per_page: '48' } }

      it 'returns :per_page param as integer' do
        expect(subject.pagination_per).to eq(48)
      end
    end

    context 'without :per_page in params' do
      it 'returns `.pagination_per_default`' do
        expect(subject.pagination_per).to eq(12)
      end
    end
  end
end
