# frozen_string_literal: true
module BlogPosts
  class Show < ApplicationView
    def page_title
      mustache[:page_title] ||= [@blog_post.title, site_title].join(' - ')
    end

    def content
      {
        blog_title: presenter.title,
        body: presenter.body,
        has_authors: presenter.has_authors?,
        authors: presenter.authors,
        has_tags: presenter.has_tags?,
        tags: presenter.tags,
        label: presenter.label,
        date: presenter.date,
        introduction: presenter.introduction,
        blog_image: presenter.image(:url)
      }
    end

    protected

    def presenter
      @presenter ||= BlogPostPresenter.new(@blog_post)
    end
  end
end
