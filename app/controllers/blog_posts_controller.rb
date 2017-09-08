# frozen_string_literal: true

require 'openssl'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

##
# Handles listing and display of blog posts retrieved from Europeana Pro via
# JSON API.
#
class BlogPostsController < ApplicationController
  include CacheHelper
  include HomepageHeroImage
  include PaginatedController
  include ProJsonApiConsumer

  self.pagination_per_default = 6

  attr_reader :body_cache_key
  helper_method :body_cache_key

  def index
    @blog_posts = Pro::BlogPost.includes(:persons).where(pro_json_api_filters).
                  order(datepublish: :desc).
                  page(pagination_page).per(pagination_per).all
    @hero_image = homepage_hero_image

    respond_to do |format|
      format.html
      format.rss
    end
  end

  def show
    @body_cache_key = "blogs/#{params[:slug]}.#{request.format.to_sym}"

    unless body_cached?
      results = Pro::BlogPost.includes(:network).where(pro_json_api_filters).
                where(slug: params[:slug])
      @blog_post = results.first
      fail JsonApiClient::Errors::NotFound.new(results.links.links['self']) if @blog_post.nil?
    end

    respond_to do |format|
      format.html
    end
  end

  protected

  def pro_json_api_whitelisted_collections
    Collection.where(key: %w(fashion world-war-I))
  end
end
