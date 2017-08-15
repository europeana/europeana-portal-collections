RSpec.describe Facet::SimplePresenter, presenter: :facet do
  let(:field_name) { 'SIMPLE_FIELD' }
  let(:field_options) { {} }

  it_behaves_like 'a facet presenter'
  it_behaves_like 'a single-selectable facet'
  it_behaves_like 'a text-labelled facet item presenter'
  it_behaves_like 'a field-showing/hiding presenter'

  describe '#display' do
    subject { presenter.display }

    it 'flags the facet as simple' do
      expect(subject[:simple]).to be(true)
    end

    describe 'the language facet' do
      let(:field_name) { 'LANGUAGE' }
      let(:items) { facet_items(1) }

      context 'when the value is in the I18nData gem' do
        before do
          allow(items.first).to receive(:value) { 'nl' }
        end

        it 'should use the I18nData translation' do
          expect(I18n).to_not receive(:t).with(:nl, scope: 'global.languages', default: 'XY')
          expect(subject[:items].first[:text]).to eq 'Dutch; Flemish'
        end
      end

      context 'when the value is NOT in the I18nData gem' do
        before do
          allow(items.first).to receive(:value) { 'xy' }
        end

        context 'when the value is in localeapp' do
          before do
            allow(I18n).to receive(:t) { 'default translation' }
            allow(I18n).to receive(:t).with(:xy, scope: 'global.languages', default: 'XY') { 'Localeapp Dutch' }
          end
          it 'should use the localeapp translation' do
            expect(subject[:items].first[:text]).to eq 'Localeapp Dutch'
          end
        end

        context 'when the value is not in localeapp' do
          it 'should use the formated literal value' do
            expect(subject[:items].first[:text]).to eq 'XY'
          end
        end
      end
    end

    describe 'the Country facet' do
      let(:field_name) { 'COUNTRY' }
      let(:items) { facet_items(1) }

      context 'when the value is in the I18nData gem' do
        before do
          allow(items.first).to receive(:value) { 'macedonia' }
        end

        it 'should use the I18nData translation' do
          expect(I18n).to_not receive(:t).with(:narnia, scope: 'global.facet.country', default: 'Narnia')
          expect(subject[:items].first[:text]).to eq 'Macedonia, Republic of'
        end
      end

      context 'when the value is NOT in the I18nData gem' do
        before do
          allow(items.first).to receive(:value) { 'narnia' }
        end

        context 'when the value is in localeapp' do
          before do
            allow(I18n).to receive(:t) { 'default translation' }
            allow(I18n).to receive(:t).with(:narnia, scope: 'global.facet.country', default: 'Narnia') { 'Localeapp Narnia' }
          end
          it 'should use the localeapp translation' do
            expect(subject[:items].first[:text]).to eq 'Localeapp Narnia'
          end
        end

        context 'when the value is not in localeapp' do
          it 'should use the formated literal value' do
            expect(subject[:items].first[:text]).to eq 'Narnia'
          end
        end
      end
    end
  end
end
