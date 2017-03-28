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
    @blog_posts = Pro::BlogPost.includes(:network).
                  where(filters).
                  page(pagination_page).per(pagination_per).all
    @hero_image = homepage_hero_image
    @theme_filters = theme_filters
    @selected_theme = theme
  end

  def show
    result = Pro::BlogPost.includes(:network).where(filters).where(slug: params[:slug])
    @blog_post = result.first

    fail JsonApiClient::Errors::NotFound.new(result.links.links['self']) if @blog_post.nil?
  end

  protected

  def filters
    {}.tap do |filters|
      filters[:blogs] = (theme_filters[theme.to_sym] || {})[:filter]
      filters[:tags] = tag unless tag.nil?
    end
  end

  def theme
    params[:theme] || 'all'
  end

  def tag
    params[:tag]
  end

  def theme_filters
    {
      all: {
        filter: 'europeana-fashion', # comma-separated list of all blogs to include
        label: t('global.actions.filter-all')
      },
      fashion: {
        filter: 'europeana-fashion',
        label: Topic.find_by_slug('fashion').label
      }
    }
  end
end
