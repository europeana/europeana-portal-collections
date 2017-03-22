# frozen_string_literal: true
require 'views/concerns/paginated_view_examples'

RSpec.describe 'blog_posts/index.html.mustache' do
  let(:view_class) { BlogPosts::Index }
  let(:pagination_per) { 6 }
  let(:pagination_page) { 1 }
  let(:blog_posts) do
    api_response = double
    allow(api_response).to receive(:body) { JSON.parse(api_responses(:pro_blog_posts)) }
    allow(api_response).to receive(:env) { {} }
    JsonApiClient::Parsers::Parser.parse(Pro::BlogPost, api_response)
  end

  before do
    allow(view).to receive(:pagination_page) { pagination_page }
    allow(view).to receive(:pagination_per) { pagination_per }
    assign(:blog_posts, blog_posts)
  end

  it_behaves_like 'paginated_view'

  it 'has page title "Europeana Blog"' do
    render
    expect(rendered).to have_selector('title', text: /Europeana Blog/, visible: false)
  end

  it 'has h2 with post title' do
    render
    expect(rendered).to have_selector('h2 a', text: blog_posts.first.title)
  end

  it 'uses blogs taxonomy for category flag' do
    render
    expect(rendered).to have_selector('.item-preview .category-flag', text: blog_posts.first.taxonomy[:blogs].values.first)
  end

  it 'has theme filter' do
    render
    expect(rendered).to have_selector('select#list_filterby')
    expect(rendered).to have_selector('select#list_filterby > option[value="all"]')
    expect(rendered).to have_selector('select#list_filterby > option[value="fashion"]')
  end
end
