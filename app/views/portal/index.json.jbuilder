# frozen_string_literal: true

json.search_results @document_list.map do |doc|
  content = Document::SearchResultPresenter.new(doc, self, @response).content
  json.extract!(content, *content.keys)
end
json.total do
  json.value @response.total
  json.formatted number_with_delimiter(@response.total)
end
