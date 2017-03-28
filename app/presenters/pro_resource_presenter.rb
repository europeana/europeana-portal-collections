# frozen_string_literal: true
##
# Presenter for resources from Pro via JSON API
class ProResourcePresenter
  include ActionView::Helpers

  attr_reader :resource, :view

  delegate :title, :introduction, :teaser, to: :resource

  def initialize(view, resource)
    @view = view
    @resource = resource
  end

  def body
    resource.body.gsub(%r{(?<=src|href)="/}, %(="#{Pro.site}/))
  end

  def image(src_key, attribute = :image)
    return nil unless resource.has_image?(attribute)
    image = resource.send(attribute)
    return nil unless image.key?(src_key) && image[src_key].present?

    {
      src: image[src_key],
      alt: image[:title]
    }
  end

  def excerpt
    truncate(strip_tags(resource.body), length: 350, separator: ' ')
  end

  def tags
    return nil unless resource.has_taxonomy?(:tags)

    { items: tags_items }
  end

  def tags_items
    return nil unless resource.has_taxonomy?(:tags)

    resource.taxonomy[:tags].map do |_pro_path, tag|
      {
        # url: view.resources_path(tag: tag),
        text: tag
      }
    end
  end

  def authors
    return nil unless resource.has_authors?

    ([persons] + [network]).flatten.compact.map do |author|
      {
        name: "#{author.first_name} #{author.last_name}",
        url: author.url
      }
    end
  end

  def network
    return nil unless resource.includes?(:network)
    resource.network.flatten.compact
  end

  def persons
    return nil unless resource.includes?(:persons)
    resource.persons.flatten.compact
  end

  # @todo this likely needs to be more generic, or moved into a blog presenter
  #   subclass
  def label
    return nil unless resource.has_taxonomy?(:blogs)
    resource.taxonomy[:blogs].values.first
  end

  def geolocation
    return nil unless resource.includes?(:locations)
    resource.locations.first.geolocation
  end

  def date
    fmt_datetime_as_date(resource.datepublish)
  end

  def date_range(from_attribute, to_attribute)
    start_datetime = resource.respond_to?(from_attribute) ? resource.send(from_attribute) : nil
    start_date = fmt_datetime_as_date(start_datetime)

    end_datetime = resource.respond_to?(to_attribute) ? resource.send(to_attribute) : nil
    end_date = fmt_datetime_as_date(end_datetime)

    return nil if [start_date, end_date].all?(&:blank?)
    [start_date, end_date].compact.uniq.join(' - ')
  end

  def fmt_datetime_as_date(datetime)
    return nil if datetime.nil?
    DateTime.parse(datetime).strftime('%-d %B, %Y') # @todo Localeapp the date format
  end

  def location_name
    resource.includes?(:locations) ? resource.locations.first.title : nil
  end

  def read_time
    # @todo implement
  end
end
