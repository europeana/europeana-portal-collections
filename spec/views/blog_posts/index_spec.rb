# frozen_string_literal: true
require 'views/concerns/paginated_view_examples'

RSpec.describe 'blog_posts/index.html.mustache' do
  let(:view_class) { BlogPosts::Index }

  it_behaves_like 'paginated_view'
end
