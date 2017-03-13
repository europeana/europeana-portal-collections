# frozen_string_literal: true
module BlogPosts
  # @todo move the blog_item_x methods into a presenter?
  class Index < ApplicationView
    include BlogPostDisplayingView
    include PaginatedView

    def page_title
      mustache[:page_title] ||= begin
        [t('site.blogs.list.page-title'), site_title].join(' - ')
      end
    end

    def hero
      {
        hero_image: @hero_image.present? && @hero_image.file.present? ? @hero_image.file.url : nil
      }
    end

    def navigation
      mustache[:navigation] ||= begin
        {
          pagination: pagination_navigation
        }.reverse_merge(super)
      end
    end

    def blog_items
      @blog_posts.map { |post| blog_item(post) }
    end

    protected

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

    def blog_item(post)
      {
        authors: blog_item_authors(post),
        title: post.title,
        object_url: blog_post_path(post),
        description: blog_item_description(post),
        read_time: nil,
        date: blog_item_date(post),
        img: blog_item_image(post),
        tags: blog_item_tags(post),
        label: blog_item_label(post)
      }
    end

    def blog_item_image(post)
      return nil unless post.respond_to?(:image) && post.image.is_a?(Hash)
      return nil unless post.image.key?(:thumbnail) && post.image[:thumbnail].present?
      {
        src: post.image[:thumbnail],
        alt: post.image[:title]
      }
    end

    def blog_item_date(post)
      DateTime.strptime(post.datepublish).strftime('%-d %B, %Y') # @todo Localeapp the date format
    end

    def blog_item_description(post)
      truncate(strip_tags(post.body), length: 350, separator: ' ')
    end

    def blog_item_label(post)
      return nil unless post.respond_to?(:taxonomy)
      return nil unless post.taxonomy.key?(:blogs) && post.taxonomy[:blogs].present?
      post.taxonomy[:blogs].values.first
    end
  end
end
