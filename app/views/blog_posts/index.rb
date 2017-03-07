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
          text: '<ol>' + @blog_posts.map { |bp| "<li>#{bp.title}#{blog_post_authors(bp)}</li>" }.join + '</ol>',
        }.reverse_merge(super)
      end
    end

    protected

    def blog_post_authors(blog_post)
      return nil unless blog_post.respond_to?(:network) && blog_post.network.present?

      author_names = blog_post.network.compact.map do |network|
        "#{network.first_name} #{network.last_name}"
      end.join(', ')
      " (#{author_names})"
    end
  end
end
