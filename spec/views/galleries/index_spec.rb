# frozen_string_literal: true
require 'views/concerns/paginated_view_examples'

RSpec.describe 'galleries/index.html.mustache' do
  let(:view_class) { Galleries::Index }

  it_behaves_like 'paginated_view'
end
