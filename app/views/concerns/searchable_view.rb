##
# View methods for searching
module SearchableView
  extend ActiveSupport::Concern

  def form_search
    {
      action: search_action_path(only_path: true),
      autocomplete: {
        url: 'http://test-entity.europeana.eu/entity/suggest?wskey=apidemo&text=',
        translations: {
          agents: t('global.navigation.agents', default: 'People'),
          concepts: t('global.navigation.concepts', default: 'Topics'),
          places: t('global.navigation.places', default: 'Places')
        }
      }
    }
  end

  # model for the search form
  def input_search
    {
      title: t('global.search-area.search-button-image-alt'),
      input_name: params[:q].blank? ? 'q' : 'qf[]',
      has_original: !params[:q].blank?,
      input_original: {
        value:  params[:q].blank? ? nil : params[:q],
        remove: search_action_url(remove_q_param(params))
      },
      input_values: input_search_values(*search_param_keys),
      placeholder: t('site.search.placeholder.text')
    }
  end

  protected

  # @param keys [Symbol] keys of params to gather template input field data for
  # @return [Array<Hash>]
  def input_search_values(*keys)
    return [] if keys.blank?

    keys.map do |k|
      [params[k]].flatten.compact.reject(&:blank?).map do |v|
        {
          name: params[k].is_a?(Array) ? "#{k}[]" : k.to_s,
          is_mlt: k.to_s == 'mlt',
          value: k.to_s == 'mlt' ? params[:mlt] : input_search_param_value(k, v),
          remove: k.to_s == 'mlt' && params[:q].blank? && params[:qf].blank? ? mlt_src : search_action_url(remove_search_param(k, v, params))
        }
      end
    end.flatten.compact
  end

  ##
  # Returns text to display on-screen for an active search param
  #
  # @param key [Symbol] parameter key
  # @param value value of the parameter
  # @return [String] text to display
  def input_search_param_value(key, value)
    case key
    when :mlt
      response, doc = controller.fetch(value)
      item = render_index_field_value(doc, ['dcTitleLangAware', 'title'])
      t('site.search.similar.prefix', mlt_item: item)
    else
      value.to_s
    end
  end

  ##
  # Keys of parameters to preserve across searches as hidden input fields
  #
  # @return [Array<Symbol>]
  def search_param_keys
    [:qf, :mlt]
  end
end
