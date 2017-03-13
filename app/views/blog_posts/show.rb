# frozen_string_literal: true
module BlogPosts
  class Show < ApplicationView
    include BlogPostDisplayingView

    def page_title
      mustache[:page_title] ||= [blog_title, site_title].join(' - ')
    end

    def blog_title
      @blog_post.title
    end

    def blog_image
      return nil unless @blog_post.respond_to?(:image) && @blog_post.image.is_a?(Hash)
      return nil unless @blog_post.image.key?(:url) && @blog_post.image[:url].present?

      {
        url: @blog_post.image[:url]
      }
    end

    def content
      @blog_post.body
    end

    def date
      blog_item_date(@blog_post)
    end

    def introduction
      @blog_post.introduction
    end

    def label
      mustache[:label] ||= blog_item_label(@blog_post)
    end

    def has_tags?
      tags.present?
    end
    alias_method :has_tags, :has_tags?

    def tags
      mustache[:tags] ||= blog_item_tags(@blog_post)
    end

    def has_authors?
      authors.present?
    end
    alias_method :has_authors, :has_authors?

    def authors
      mustache[:authors] ||= blog_item_authors(@blog_post)
    end

    def read_time
      # @todo implement
    end
  end
end
