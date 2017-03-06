# frozen_string_literal: true
class BlogPostsController < ApplicationController
  def index
    @blog_posts = Pro::BlogPost.page(blog_posts_page).per(6).all
  end

  protected

  def blog_posts_page
    (params[:page] || 1).to_i
  end
end

