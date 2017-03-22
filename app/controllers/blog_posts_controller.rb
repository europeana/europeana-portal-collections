# frozen_string_literal: true
##
# Handles listing and display of blog posts retrieved from Europeana Pro via
# JSON API.
#
# @todo Exception handling when `JsonApiClient` requests fail
class BlogPostsController < ApplicationController
  include HomepageHeroImage
  include PaginatedController

  self.pagination_per_default = 6

  def index
    @blog_posts = themed_blog_posts.page(pagination_page).per(pagination_per).all
    @hero_image = homepage_hero_image
    @selected_theme = blog_posts_theme
  end

  def show
    @blog_post = pro_blog_posts.where(slug: params[:slug]).first
  end

  protected

  def pro_blog_posts
    Pro::BlogPost.includes(:network, :persons)
  end

  def themed_blog_posts
    blog_posts_theme == 'all' ? pro_blog_posts : pro_blog_posts.where(tags: blog_posts_theme)
  end

  def blog_posts_theme
    params[:theme] || 'all'
  end
end
