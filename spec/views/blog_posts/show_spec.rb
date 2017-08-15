# frozen_string_literal: true

RSpec.describe 'blog_posts/show.html.mustache', :common_view_components, :stable_version_view do
  let(:view_class) { BlogPosts::Show }

  let(:blog_post) do
    api_response = double
    allow(api_response).to receive(:body) { JSON.parse(api_responses(:pro_blog_posts)) }
    allow(api_response).to receive(:env) { {} }
    JsonApiClient::Parsers::Parser.parse(Pro::BlogPost, api_response).first
  end

  before do
    assign(:blog_post, blog_post)
    assign(:params, slug: blog_post.slug)
    allow(view).to receive(:cache_body?) { false }
  end

  it 'has page title with post title' do
    render
    expect(rendered).to have_selector('title', text: blog_post.title, visible: false)
  end

  it 'displays full post body' do
    render
    expect(rendered).to include(blog_post.body)
  end

  it 'has breadcrumb link to blog index' do
    render
    expect(rendered).to have_selector('.breadcrumbs li a[href="/en/blogs"]', text: 'Blog')
  end
end
