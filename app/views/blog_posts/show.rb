# frozen_string_literal: true
module BlogPosts
  class Show < ApplicationView
    include BlogPostDisplayingView

    def blog_title
      @blog_post.title
    end

    def blog_image
    
    end

    def content
      @blog_post.body
    end

    def date
    
    end

    def introduction
      @blog_post.introduction
    end

    def label
      
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
