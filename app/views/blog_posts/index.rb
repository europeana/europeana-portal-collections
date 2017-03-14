# frozen_string_literal: true
module BlogPosts
  class Index < ApplicationView
    include PaginatedView

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

    protected

    def blog_item(post)
      presenter = BlogPostPresenter.new(post)
      {
        has_authors: presenter.has_authors?,
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

    def pagination_current_page
      mustache[:pagination_current_page] ||= begin
        # JsonApiClient::ResultSet#current_page always returns 1 here for some reason
        # @blog_posts.current_page

        # Get it out of the controller-assigned var instead
        @pagination_page
      end
    end

    def pagination_per_page
      mustache[:pagination_per_page] ||= begin
        # JsonApiClient::ResultSet#per_page always returns number in this page
        # here for some reason
        # @blog_posts.per_page

        # Get it out of the controller-assigned var instead
        @pagination_per
      end
    end

    def pagination_total
      # JsonApiClient::ResultSet#total_count always returns number in this page
      # here for some reason
      # @blog_posts.total_pages
      if @blog_posts.respond_to?(:meta) && @blog_posts.meta.respond_to?(:total)
        @blog_posts.meta.total
      else
        0
      end
    end

    def pagination_total_pages
      mustache[:pagination_total_pages] ||= begin
        # JsonApiClient::ResultSet#total_pages always returns 1 here for some reason
        # @blog_posts.total_pages
        (pagination_total / pagination_per_page) +
          ((pagination_total / pagination_per_page).zero? ? 0 : 1)
      end
    end
  end
end
