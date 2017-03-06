# frozen_string_literal: true
module BlogPosts
  class Index < ApplicationView
    def page_title
      mustache[:page_title] ||= begin
        ['Blog posts', site_title].join(' - ') # @todo Localeapp
      end
    end

    def content
      mustache[:content] ||= begin
        {
          title: 'Blog posts', # @todo Localeapp
          text: '<ol>' + @blog_posts.map { |bp| '<li>' + bp.title + '</li>' }.join + '</ol>',
        }.reverse_merge(super)
      end
    end
  end
end
