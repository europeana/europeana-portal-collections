# frozen_string_literal: true

module ProJsonApiConsumingView
  extend ActiveSupport::Concern

  protected

  def pro_json_api_posts_for_record_url(record_id)
    URI.parse(Pro::Post.site).tap do |uri|
      uri.path += Pro::Post.path
      uri.query = Rack::Utils.build_nested_query(
        contains: {
          image_attribution_link: record_id
        },
        page: {
          size: 6
        },
        sort: '-datepublish'
      )
    end.to_s
  end
end
