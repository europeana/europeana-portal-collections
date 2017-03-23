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
    @blog_posts = Pro::BlogPost.includes(:network, :persons).
                  where(blog_post_filters).
                  page(pagination_page).per(pagination_per).all
    @hero_image = homepage_hero_image
    @selected_theme = blog_posts_theme
  end

  def show
    @blog_post = Pro::BlogPost.includes(:network, :persons).
                 where(slug: params[:slug]).first
  end

  protected

  def blog_post_filters
    { tags: 'culturelover' }.tap do |filters|
      if blog_posts_theme == 'fashion'
        filters[:blogs] = 'Europeana Fashion Blog'
      end
    end
  end

  def blog_posts_theme
    params[:theme] || 'all'
  end
end
