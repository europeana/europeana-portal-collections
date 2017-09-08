# frozen_string_literal: true

module BlogPosts
  class Index < ApplicationView
    include PaginatedJsonApiResultSetView
    include ThemeFilterableView

    def head_links
      mustache[:head_links] ||= begin
        { items: [{ rel: 'alternate', type: 'application/rss+xml', href: blog_posts_url(format: 'rss') }] + super[:items] }
      end
    end

    def theme_filters
      pro_json_api_theme_filters
    end

    def selected_theme
      pro_json_api_selected_theme
    end

    def page_content_heading
      t('site.blogs.list.page-title')
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
      theme_filter_options
    end

    protected

    def blog_item(post)
      presenter = ProResourcePresenter.new(self, post)
      {
        has_authors: post.has_authors?,
        authors: presenter.authors,
        title: presenter.title,
        object_url: blog_post_path(slug: post.slug),
        description: presenter.excerpt,
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
