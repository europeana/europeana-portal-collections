# frozen_string_literal: true

RSpec.describe RenderConstraintsHelper do
  it { is_expected.to include(Blacklight::RenderConstraintsHelperBehavior) }

  describe '#query_has_constraints?' do
    subject { helper.query_has_constraints?(params) }
    context 'params has f' do
      let(:params) { { f: { 'YEAR': [1950] } } }
      it { is_expected.to eq(true) }
    end

    context 'params has q' do
      let(:params) { { q: 'paris' } }
      it { is_expected.to eq(true) }
    end

    context 'params has qf' do
      let(:params) { { qf: 'paintings' } }
      it { is_expected.to eq(true) }
    end

    context 'params has no f, q, qf' do
      let(:params) { { rows: 12 } }
      it { is_expected.to eq(false) }
    end
  end

  describe '#render_constraints' do
    subject { helper.render_constraints({}) }
    it 'combines output of other helpers' do
      allow(helper).to receive(:render_constraints_query).and_return('1')
      allow(helper).to receive(:render_constraints_filters).and_return('2')
      allow(helper).to receive(:render_constraints_qfs).and_return('3')
      expect(subject).to eq('123')
    end
  end

  describe '#render_constraints_query' do
    it 'should not set action'
  end

  describe '#render_constraints_qfs' do
    subject { helper.render_constraints_qfs(params) }

    context 'without qf params' do
      let(:params) { { q: 'hat' } }
      it { is_expected.to eq('') }
    end

    context 'with qf params' do
      before do
        def helper.search_action_path(*_); end

        def helper.remove_search_param(*_); end
      end
      let(:params) { { q: 'hat', qf: %w(scarf glasses) } }
      it { is_expected.not_to eq('') }
    end
  end

  describe '#render_qf_element' do
    it 'does stuff'
  end
end
