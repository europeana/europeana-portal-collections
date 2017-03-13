# frozen_string_literal: true
module BlogPostDisplayingView
  extend ActiveSupport::Concern

  protected

  def blog_item_tags(post)
    items = blog_item_tags_items(post)
    items.nil? ? nil : { items: items }
  end

  def blog_item_tags_items(post)
    return nil unless post.respond_to?(:taxonomy)
    return nil unless post.taxonomy.key?(:tags) && post.taxonomy[:tags].present?

    post.taxonomy[:tags].map do |pro_path, tag|
      {
        url: pro_blog_url(pro_path),
        text: tag
      }
    end
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

  def blog_item_label(post)
    return nil unless post.respond_to?(:taxonomy)
    return nil unless post.taxonomy.key?(:blogs) && post.taxonomy[:blogs].present?

    post.taxonomy[:blogs].values.first
  end

  def blog_item_date(post)
    DateTime.strptime(post.datepublish).strftime('%-d %B, %Y') # @todo Localeapp the date format
  end

  def pro_blog_url(path)
    Pro.site + path
  end
end
