# frozen_string_literal: true
module BlogPosts
  class Index < ApplicationView
    include PaginatedJsonApiResultSetView

    def page_title
      mustache[:page_title] ||= begin
        [t('site.blogs.list.page-title'), site_title].join(' - ')
      end
    end

    def hero
      mustache[:hero] ||= begin
        {
          hero_image: @hero_image.present? && @hero_image.file.present? ? @hero_image.file.url : nil
        }
      end
    end

    def navigation
      mustache[:navigation] ||= begin
        {
          pagination: pagination_navigation
        }.reverse_merge(super)
      end
    end

    def blog_items
      mustache[:blog_items] ||= @blog_posts.map { |post| blog_item(post) }
    end

    def blogs_filter_options
      return nil unless config.x.enable.blog_posts_theme_filter
      {
        filter_name: 'theme',
        options: filter_options
      }
    end

    protected

    def filter_options
      @theme_filters.map { |key, data| { label: data[:label], value: key } }.tap do |options|
        selected_option = options.delete(options.detect { |option| option[:value] == @selected_theme })
        options.unshift(selected_option) unless selected_option.nil?
      end
    end

    def blog_item(post)
      presenter = BlogPostPresenter.new(self, post)
      {
        has_authors: post.has_authors?,
        authors: presenter.authors,
        title: presenter.title,
        object_url: blog_post_path(slug: post.slug),
        description: presenter.excerpt,
        read_time: presenter.read_time,
        date: presenter.date,
        img: presenter.image(:thumbnail),
        tags: presenter.tags,
        label: presenter.label
      }
    end

    def paginated_set
      @blog_posts
    end
  end
end
