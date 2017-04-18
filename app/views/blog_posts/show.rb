# frozen_string_literal: true
module BlogPosts
  class Show < ApplicationView
    def blog_title
      presenter.title
    end
    alias_method :page_content_heading, :blog_title

    def content
      mustache[:content] ||= begin
        {
          body: presenter.body,
          has_authors: @blog_post.has_authors?,
          authors: presenter.authors,
          has_tags: @blog_post.has_taxonomy?(:tags),
          tags: presenter.tags,
          label: presenter.label,
          date: presenter.date,
          introduction: presenter.introduction,
          blog_image: presenter.image(:url),
          read_time: presenter.read_time
        }
      end
    end

    def navigation
      mustache[:navigation] ||= begin
        {
          back_url: blog_posts_path,
          back_label: t('site.blogs.list.page-title')
        }.reverse_merge(super)
      end
    end

    protected

    def presenter
      @presenter ||= ProResourcePresenter.new(self, @blog_post)
    end
  end
end
