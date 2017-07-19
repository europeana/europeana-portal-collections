# frozen_string_literal: true

module Europeana
  module Entities
    extend ActiveSupport::Concern

    protected

    def build_query_items_by(params)
      suffix = "#{params[:type]}/#{params[:namespace]}/#{params[:identifier]}"
      creator = build_proxy_dc('creator', 'http://data.europeana.eu', suffix)
      contributor = build_proxy_dc('contributor', 'http://data.europeana.eu', suffix)
      "#{creator} OR #{contributor}"
    end

    private

    def build_proxy_dc(name, url, suffix)
      "proxy_dc_#{name}:\"#{url}/#{suffix}\""
    end
  end
end
