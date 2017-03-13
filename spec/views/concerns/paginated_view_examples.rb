# frozen_string_literal: true
shared_examples_for 'paginated_view' do
  describe 'view class' do
    subject { view_class }
    it { is_expected.to include(PaginatedView) }

    it 'implements #paginated_set' do
      expect { view_class.new.send(:paginated_set) }.not_to raise_exception
    end
  end
end
