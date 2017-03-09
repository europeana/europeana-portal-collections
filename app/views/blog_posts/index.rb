# frozen_string_literal: true
module BlogPosts
  # @todo move the blog_item_x methods into a presenter?
  class Index < ApplicationView
    include PaginatedView

    def page_title
      mustache[:page_title] ||= begin
        ['Europeana Blog', site_title].join(' - ') # @todo Localeapp
      end
    end

    def hero
      {
        hero_image: @hero_image.file.present? ? @hero_image.file.url : nil
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

    def pagination_page_item_count
      @blog_posts.count
    end

    def pagination_current_page
      mustache[:pagination_current_page] ||= begin
        # JsonApiClient::ResultSet#current_page always returns 1 here for some reason
        # @blog_posts.current_page

        # Get it out of the JSON API self link instead
        current_page_api_query = URI.parse(@blog_posts.links.links['self']).query
        Rack::Utils.parse_nested_query(current_page_api_query)['page']['number'].to_i
      end
    end

    def pagination_per_page
      mustache[:pagination_per_page] ||= begin
        # JsonApiClient::ResultSet#per_page always returns number in this page
        # here for some reason
        # @blog_posts.per_page

        # Get it out of the JSON API self link instead
        current_page_api_query = URI.parse(@blog_posts.links.links['self']).query
        Rack::Utils.parse_nested_query(current_page_api_query)['page']['size'].to_i
      end
    end

    def pagination_total
      # JsonApiClient::ResultSet#total_count always returns number in this page
      # here for some reason
      # @blog_posts.total_pages
      @blog_posts.meta.total
    end

    def pagination_total_pages
      mustache[:pagination_total_pages] ||= begin
        # JsonApiClient::ResultSet#total_pages always returns 1 here for some reason
        # @blog_posts.total_pages
        (pagination_total / pagination_per_page) +
          ((pagination_total / pagination_per_page).zero? ? 0 : 1)
      end
    end

    def pro_blog_url(path)
      Pro.site + path
    end

    def blog_item(post)
      {
        authors: blog_item_authors(post),
        title: post.title,
        description: blog_item_description(post),
        read_time: nil,
        date: blog_item_date(post),
        img: blog_item_image(post),
        tags: blog_item_tags(post),
        label: blog_item_label(post)
      }
    end

    def blog_item_tags(post)
      return nil unless post.respond_to?(:taxonomy)
      return nil unless post.taxonomy.key?(:tags) && post.taxonomy[:tags].present?
      { items: blog_item_tags_items(post) }
    end

    def blog_item_tags_items(post)
      post.taxonomy[:tags].map do |k, v|
        {
          url: pro_blog_url(k),
          text: v
        }
      end
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

    def blog_item_authors(post)
      return nil unless post.respond_to?(:network) && post.network.present?

      post.network.compact.map do |network|
        {
          name: "#{network.first_name} #{network.last_name}",
          url: network.url
        }
      end
    end
  end
end
