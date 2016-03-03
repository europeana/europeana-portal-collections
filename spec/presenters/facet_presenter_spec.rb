RSpec.describe FacetPresenter do
  def facet_items(count)
    (1..count).map do |n|
      Europeana::Blacklight::Response::Facets::FacetItem.new(value: "Item #{n}", hits: (count + 1 - n) * 100 )
    end
  end

  let(:controller) { PortalController.new }
  let(:blacklight_config) do
    Blacklight::Configuration.new do |config|
      config.add_facet_field 'SIMPLE_FIELD'
      config.add_facet_field 'HIERARCHICAL_PARENT_FIELD', hierarchical: true
      config.add_facet_field 'HIERARCHICAL_CHILD_FIELD', hierarchical: true, parent: 'HIERARCHICAL_PARENT_FIELD'
      config.add_facet_field 'BOOLEAN_FIELD', boolean: true
      config.add_facet_field 'COLOUR_FIELD', colour: true
      config.add_facet_field 'RANGE_FIELD', range: true
      config.add_facet_field 'SINGLE_SELECT_FIELD', single: true
    end
  end
  let(:facet_field_class) { Europeana::Blacklight::Response::Facets::FacetField }

  before do
    controller.request = ActionController::TestRequest.new
  end

  describe '.build' do
    subject { described_class.build(facet, controller, blacklight_config) }

    context 'when facet is a simple field' do
      let(:facet) { facet_field_class.new('SIMPLE_FIELD', []) }
      it { is_expected.to be_a(Facet::SimplePresenter) }
    end

    context 'when facet is a hierarchical field' do
      context 'with no parent' do
        let(:facet) { facet_field_class.new('HIERARCHICAL_PARENT_FIELD', []) }
        it { is_expected.to be_a(Facet::HierarchicalPresenter) }
      end
      context 'with a parent' do
        let(:facet) { facet_field_class.new('HIERARCHICAL_CHILD_FIELD', []) }
        it { is_expected.to be_a(Facet::SimplePresenter) }
      end
    end

    context 'when facet is a boolean field' do
      let(:facet) { facet_field_class.new('BOOLEAN_FIELD', []) }
      it { is_expected.to be_a(Facet::BooleanPresenter) }
    end

    context 'when facet is a colour field' do
      let(:facet) { facet_field_class.new('COLOUR_FIELD', []) }
      it { is_expected.to be_a(Facet::ColourPresenter) }
    end

    context 'when facet is a range field' do
      let(:facet) { facet_field_class.new('RANGE_FIELD', []) }
      it { is_expected.to be_a(Facet::RangePresenter) }
    end
  end

  describe '#display' do
    let(:facet) { facet_field_class.new('SIMPLE_FIELD', []) }
    let(:options) { {} }
    subject { described_class.new(facet, controller, blacklight_config).display(options) }

    it { is_expected.to be_a(Hash) }

    it 'should include a translated title' do
      I18n.backend.store_translations(:en, global: { facet: { header: { simple_field: 'simple field title' } } })
      expect(subject[:title]).to eq('simple field title')
    end

    context 'when facet is single-select' do
      let(:facet) { facet_field_class.new('SINGLE_SELECT_FIELD', []) }
      it 'should include select_one: true' do
        expect(subject[:select_one]).to be(true)
      end
    end

    context 'when facet is not single-select' do
      it 'should include select_one: nil' do
        expect(subject[:select_one]).to be_nil
      end
    end

    context 'when options[:count] is 4 and facet has 6 items' do
      let(:options) { { count: 4 } }
      let(:items) { facet_items(6) }
      let(:facet) { facet_field_class.new('SIMPLE_FIELD', items) }
      it 'should have 4 unhidden items' do
        expect(subject[:items].length).to eq(4)
      end
      it 'should have 2 unhidden items' do
        expect(subject[:extra_items][:items].length).to eq(2)
      end
    end
  end
end
