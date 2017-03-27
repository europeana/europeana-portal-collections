# frozen_string_literal: true
class BlogPostPresenter
  include ActionView::Helpers

  attr_reader :blog_post, :view

  delegate :title, :introduction, to: :blog_post

  def initialize(view, blog_post)
    @view = view
    @blog_post = blog_post
  end

  def body
    blog_post.body.gsub(%r{(?<=src|href)="/}, %(="#{Pro.site}/))
  end

  def image(source_key)
    return nil unless blog_post.has_image?
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
    return nil unless blog_post.has_taxonomy?(:tags)

    { items: tags_items }
  end

  def tags_items
    return nil unless blog_post.has_taxonomy?(:tags)

    blog_post.taxonomy[:tags].map do |_pro_path, tag|
      {
        # url: view.blog_posts_path(tag: tag),
        text: tag
      }
    end
  end

  def authors
    return nil unless blog_post.has_authors?

    ([persons] + [network]).flatten.compact.map do |author|
      {
        name: "#{author.first_name} #{author.last_name}",
        url: author.url
      }
    end
  end

  def network
    return nil unless blog_post.includes?(:network)
    blog_post.network.flatten.compact
  end

  def persons
    return nil unless blog_post.includes?(:persons)
    blog_post.persons.flatten.compact
  end

  def label
    return nil unless blog_post.has_taxonomy?(:blogs)
    blog_post.taxonomy[:blogs].values.first
  end

  def date
    DateTime.strptime(blog_post.datepublish).strftime('%-d %B, %Y') # @todo Localeapp the date format
  end

  def read_time
    # @todo implement
  end
end
