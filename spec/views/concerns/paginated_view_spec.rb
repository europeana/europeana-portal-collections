# frozen_string_literal: true
RSpec.describe PaginatedView do
  let(:view_class) do
    Class.new do
      include PaginatedView
    end
  end

  subject { view_class.new }

  before do
    allow(subject).to receive(:mustache) { {} }
    allow(subject).to receive(:paginated_set) { paginated_set }
  end

  context 'when paginated set is empty' do
    before do
      allow(subject).to receive(:paginated_set) { [] }
    end

    it { is_expected.not_to have_results }
    it { is_expected.not_to have_single_result }
    it { is_expected.not_to have_multiple_results }
  end

  context 'when paginated set has one member' do
    let(:paginated_set) { [4] }

    it { is_expected.to have_results }
    it { is_expected.to have_single_result }
    it { is_expected.not_to have_multiple_results }
  end

  context 'when paginated set has multiple members' do
    let(:paginated_set) { [1, 2] }

    it { is_expected.to have_results }
    it { is_expected.not_to have_single_result }
    it { is_expected.to have_multiple_results }
  end
end
