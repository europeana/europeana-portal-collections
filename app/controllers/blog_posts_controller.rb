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
    @blog_posts = pro_blog_posts.page(pagination_page).per(pagination_per).all
    @hero_image = homepage_hero_image
  end

  def show
    @blog_post = pro_blog_posts.where(slug: params[:slug]).first
  end

  protected

  def pro_blog_posts
    Pro::BlogPost.includes(:network, :persons)
  end
end
