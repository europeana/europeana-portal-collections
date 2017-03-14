# frozen_string_literal: true
class BlogPostPresenter
  include ActionView::Helpers

  attr_reader :blog_post

  delegate :title, :introduction, to: :blog_post

  def initialize(blog_post)
    @blog_post = blog_post
  end

  def has_taxonomy?
    blog_post.respond_to?(:taxonomy)
  end

  def has_tags?
    return false unless has_taxonomy?
    blog_post.taxonomy.key?(:tags) && blog_post.taxonomy[:tags].present?
  end

  def has_authors?
    persons.present? || network.present?
  end

  def has_label?
    return false unless has_taxonomy?
    blog_post.taxonomy.key?(:blogs) && blog_post.taxonomy[:blogs].present?
  end

  def has_image?
    blog_post.respond_to?(:image) && blog_post.image.is_a?(Hash)
  end

  def body
    blog_post.body.gsub(%r{(?<=src|href)="/}, %(="#{Pro.site}/))
  end

  def image(source_key)
    return nil unless has_image?
    return nil unless blog_post.image.key?(source_key) && blog_post.image[source_key].present?

    {
      src: blog_post.image[source_key],
      alt: blog_post.image[:title]
    }
  end

  def excerpt
    truncate(strip_tags(blog_post.body), length: 350, separator: ' ')
  end

  def tags
    return nil unless has_tags?

    { items: tags_items }
  end

  def tags_items
    return nil unless has_tags?

    blog_post.taxonomy[:tags].map do |pro_path, tag|
      {
        url: pro_url(pro_path),
        text: tag
      }
    end
  end

  def authors
    return nil unless has_authors?

    ([persons] + [network]).flatten.compact.map do |author|
      {
        name: "#{author.first_name} #{author.last_name}",
        url: author.url
      }
    end
  end

  def network
    blog_post.respond_to?(:network) ? blog_post.network.flatten.compact : nil
  end

  def persons
    blog_post.respond_to?(:persons) ? blog_post.persons.flatten.compact : nil
  end

  def label
    return nil unless has_label?

    blog_post.taxonomy[:blogs].values.first
  end

  def date
    DateTime.strptime(blog_post.datepublish).strftime('%-d %B, %Y') # @todo Localeapp the date format
  end

  def pro_url(path)
    Pro.site + path
  end

  def read_time
    # @todo implement
  end
end
