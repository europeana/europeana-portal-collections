# frozen_string_literal: true
##
# Handles listing and display of blog posts retrieved from Europeana Pro via
# JSON API.
#
# @todo Exception handling when `JsonApiClient` requests fail
class BlogPostsController < ApplicationController
  include CacheHelper
  include HomepageHeroImage
  include PaginatedController

  self.pagination_per_default = 6

  attr_reader :body_cache_key
  helper_method :body_cache_key

  def index
    @blog_posts = Pro::BlogPost.includes(:network).
                  where(filters).
                  page(pagination_page).per(pagination_per).all
    @hero_image = homepage_hero_image
    @theme_filters = theme_filters
    @selected_theme = theme

    respond_to do |format|
      format.html
    end
  end

  def show
    @body_cache_key = "blogs/#{params[:slug]}.#{request.format.to_sym}"

    unless body_cached?
      results = Pro::BlogPost.includes(:network).where(filters).where(slug: params[:slug])
      @blog_post = results.first
      fail JsonApiClient::Errors::NotFound.new(results.links.links['self']) if @blog_post.nil?
    end

    respond_to do |format|
      format.html
    end
  end

  protected

  def filters
    {}.tap do |filters|
      filters[:blogs] = (theme_filters[theme] || {})[:filter]
      filters[:tags] = tag unless tag.nil?
    end
  end

  def theme
    (params[:theme] || 'all').to_sym
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
