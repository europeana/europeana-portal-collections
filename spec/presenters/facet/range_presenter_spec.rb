# frozen_string_literal: true

# @todo spec this better when it's actually in use
RSpec.describe Facet::RangePresenter, presenter: :facet do
  let(:field_name) { 'RANGE_FIELD' }
  let(:field_options) { { range: true }.merge(context_field_options) }
  let(:context_field_options) { {} }
  let(:item_type) { :number }
  let(:items) { facet_items(20) }
  let(:params) { { range: { "#{field_name}" => { begin: items.first.value, end: items.last.value } } } }

  describe '#display' do
    subject { presenter.display }
    context 'when not a filter facet' do
      let(:context_field_options) { { filter: nil } }

      it { is_expected.to have_key(:data) }
    end

    context 'when a filter facet' do
      let(:context_field_options) { { filter: true } }

      it { is_expected.not_to have_key(:data) }
    end
  end

  describe '#hits_max' do
    let(:items) { facet_items(6) }
    subject { presenter.hits_max }
    it 'returns the maximum number of hits' do
      expect(subject).to eq(600)
    end
  end

  describe '#range_max' do
    let(:items) { facet_items(6) }
    subject { presenter.range_max }
    it 'returns the top of the range' do
      expect(subject).to eq(6)
    end
  end

  describe '#range_min' do
    let(:items) { facet_items(6) }
    subject { presenter.range_min }
    it 'returns the bottom of the range' do
      expect(subject).to eq(1)
    end
  end

  describe '#aggregated_items' do
    let(:items) { facet_items(600) }
    subject { presenter.send(:aggregated_items, items) }
    it 'returns the items aggregated into segments corresponding to max_intervals' do
      expect(subject.count).to eq(presenter.send(:max_intervals))
      expect(subject.first[:min_value]).to eq(1)
      expect(subject.first[:max_value]).to eq(6)
      expect(subject.first[:hits]).to eq(358_500)
    end
  end

  describe '#limited_items' do
    let(:items) { facet_items(6) }
    subject { presenter.send(:limited_items) }
    it 'returns the items limited to the range in the params'
    # this spec requires params set, pending for now
  end

  describe '#padded_items' do
    let(:items) { facet_items(6) }
    subject { presenter.send(:padded_items) }
    it 'returns the items with any gaps filled in with empty values'
    # this spec requires mock facets with gaps, pending for now
  end

  describe '#max_intervals' do
    let(:items) { facet_items(6) }
    subject { presenter.send(:max_intervals) }
    it 'returns the bottom of the range' do
      expect(subject).to eq(100)
    end
  end

  describe '#remove_link_params' do
    subject { presenter.remove_link_params }

    context 'with only this range facet' do
      it { is_expected.not_to have_key(:range) }
    end

    context 'with other range facet(s)' do
      let(:other_field_name) { 'ANOTHER_RANGE_FACET' }
      let(:params) do
        {
          range: {
            "#{field_name}" => { begin: items.first.value, end: items.last.value },
            "#{other_field_name}" => { begin: 10, end: 20 }
          }
        }
      end
      let(:blacklight_config) do
        Blacklight::Configuration.new do |config|
          config.add_facet_field field_name, field_options
          config.add_facet_field other_field_name, range: true
        end
      end

      it { is_expected.to have_key(:range) }
      it 'removes this facet from range link params' do
        expect(subject[:range]).not_to have_key(field_name)
      end
    end
  end

  describe '#filter_open?' do
    subject { presenter.filter_open? }

    context 'when a filter facet' do
      let(:context_field_options) { { filter: true } }
      it 'returns true' do
        expect(subject).to eq(true)
      end
    end

    context 'when not a filter facet' do
      let(:context_field_options) { { filter: nil } }
      context 'when the facet is in the search params' do
        before do
          allow(presenter).to receive(:range_in_params?) { true }
        end
        it 'returns true' do
          expect(subject).to eq(true)
        end
      end

      context 'when the facet is not the search params' do
        before do
          allow(presenter).to receive(:range_in_params?) { false }
        end
        it 'returns false' do
          expect(subject).to eq(false)
        end
      end
    end
  end
end
