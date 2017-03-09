# frozen_string_literal: true
##
# Handles listing and display of blog posts retrieved from Europeana Pro via
# JSON API.
#
# @todo Exception handling when `JsonApiClient` requests fail
# @todo Extract pagination into a controller concern
class BlogPostsController < ApplicationController
  def index
    @blog_posts = Pro::BlogPost.includes(:network).page(blog_posts_page).per(6).all
    @hero_image = homepage_hero_image
  end

  protected

  def blog_posts_page
    (params[:page] || 1).to_i
  end

  def homepage_hero_image
    landing_page = Page::Landing.find_by_slug('')
    landing_page.nil? ? nil : landing_page.hero_image
  end
end
