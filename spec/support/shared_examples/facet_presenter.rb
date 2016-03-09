shared_examples 'a facet presenter' do
  describe '#display' do
    subject { presenter.display }

    it { is_expected.to be_a(Hash) }

    it 'should include a facet label' do
      allow(presenter).to receive(:facet_label).and_return('facet label')
      expect(subject[:title]).to eq('facet label')
    end
  end

  describe '#facet_item' do
    let(:item) { facet_items(10).first }
    subject { presenter.facet_item(item) }

    it 'should include a formatted number of results' do
      expect(subject[:num_results]).to eq('1,000')
    end

    context 'when item is not in request params' do
      it 'should include URL to add facet' do
        expect(subject[:url]).to match(facet.name)
      end

      it 'should indicate facet not checked' do
        expect(subject[:is_checked]).to be(false)
      end
    end

    context 'when item is in request params' do
      let(:params) { { f: { facet.name => [item.value] } } }

      it 'should include URL to remove facet' do
        expect(subject[:url]).not_to match(facet.name)
      end

      it 'should indicate facet checked' do
        expect(subject[:is_checked]).to be(true)
      end
    end
  end

  describe '#filter_item' do
    let(:item) { facet_items(10).first }
    subject { presenter.filter_item(item) }
    let(:params) { { f: { facet.name => [item.value] } } }

    it 'should include a filter label' do
      allow(presenter).to receive(:facet_label).and_return('facet filter label')
      expect(subject[:filter]).to eq('facet filter label')
    end

    it 'should include an item label' do
      allow(presenter).to receive(:facet_item_label).and_return('item filter label')
      expect(subject[:value]).to eq('item filter label')
    end

    it 'should include URL to remove facet' do
      expect(subject[:remove]).not_to match(facet.name)
    end

    it 'should include facet URL param name' do
      expect(subject[:name]).to eq("f[#{facet.name}][]")
    end
  end
end

shared_examples 'a field-showing/hiding presenter' do
  describe '#display' do
    subject { presenter.display(options) }
    let(:options) { { count: 4 } }
    let(:items) { facet_items(6) }

    context 'when options[:count] is 4 and facet has 6 items' do
      context 'with no facet items in request params' do
        it 'should have 4 unhidden items' do
          expect(subject[:items].length).to eq(4)
        end

        it 'should have 2 hidden items' do
          expect(subject[:extra_items][:items].length).to eq(2)
        end
      end

      context 'with 5 facet items in request params' do
        let(:params) { { f: { facet.name => items[0..4].map(&:value) } } }

        it 'should have 5 unhidden items' do
          expect(subject[:items].length).to eq(5)
        end

        it 'should have 1 hidden item' do
          expect(subject[:extra_items][:items].length).to eq(1)
        end
      end
    end
  end
end

shared_examples 'a text-labelled facet item presenter' do
  describe '#facet_item' do
    let(:item) { facet_items(10).first }
    subject { presenter.facet_item(item) }

    it 'should include an item label' do
      allow(presenter).to receive(:facet_item_label).and_return('item label')
      expect(subject[:text]).to eq('item label')
    end
  end
end

shared_examples 'a single-selectable facet' do
  describe '#display' do
    subject { presenter.display }

    context 'when facet is single-select' do
      let(:field_options) { super().merge(single: true) }

      it 'should include select_one: true' do
        expect(subject[:select_one]).to be(true)
      end
    end

    context 'when facet is not single-select' do
      it 'should include select_one: nil' do
        expect(subject[:select_one]).to be_nil
      end
    end
  end
end

shared_examples 'a labeller of facets' do
  describe '#facet_label' do
    subject { presenter.facet_label }
    it 'returns a translated label for the facet' do
      I18n.backend.store_translations(:en, global: { facet: { header: { field_name.downcase => 'field title' } } })
      expect(subject).to eq('field title')
    end
  end

  describe '#facet_item_label' do
    subject { presenter.facet_item_label(facet_item) }

    context "when field is not translatable" do
      %w(PROVIDER DATA_PROVIDER COLOURPALETTE).each do |unmapped_facet|
        let(:field_name) { unmapped_facet }
        let(:facet_item) { 'unmappable text' }
        it 'does not map the text' do
          expect(subject).to match(/unmappable text/i)
        end
      end
    end

    context 'when field is MIME_TYPE' do
      let(:field_name) { 'MIME_TYPE' }

      context 'when item is "text/plain"' do
        let(:facet_item) { 'text/plain' }
        it { is_expected.to eq('TXT') }
      end

      context 'when item is "video/x-msvideo"' do
        let(:facet_item) { 'video/x-msvideo' }
        it { is_expected.to eq('AVI') }
      end

      context 'when item is "image/tiff"' do
        let(:facet_item) { 'image/tiff' }
        it { is_expected.to eq('TIFF') }
      end

      context 'when item is "video/x-ms-wmv"' do
        let(:facet_item) { 'video/x-ms-wmv' }
        it { is_expected.to eq('WMV') }
      end
    end

    context 'when field is translatable' do
      let(:facet_item) { 'ONE FACET VALUE' }
      it 'looks up a translatation' do
        I18n.backend.store_translations(:en, global: { facet: { field_name.downcase => { facet_item.downcase => 'item title' } } })
        expect(subject).to match(/item title/i)
      end
    end
  end
end
