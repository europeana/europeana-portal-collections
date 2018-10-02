# frozen_string_literal: true

RSpec.describe GeolocationHelper do
  describe '#format_latitude' do
    subject { helper.format_latitude(latitude) }

    context 'with positive value' do
      let(:latitude) { '1.0' }

      it 'should format as degrees North' do
        expect(subject).to eq("#{latitude}° North")
      end
    end

    context 'with negative value' do
      let(:latitude) { '-1.0' }

      it 'should format as degrees South' do
        expect(subject).to eq("#{latitude}° South")
      end
    end
  end

  describe '#format_longitude' do
    subject { helper.format_longitude(longitude) }

    context 'with positive value' do
      let(:longitude) { '1.0' }

      it 'should format as degrees East' do
        expect(subject).to eq("#{longitude}° East")
      end
    end

    context 'with negative value' do
      let(:longitude) { '-1.0' }

      it 'should format as degrees West' do
        expect(subject).to eq("#{longitude}° West")
      end
    end
  end
end
