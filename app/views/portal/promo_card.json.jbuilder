# frozen_string_literal: true

date = begin
  Date.parse(@resource[:date].to_s).strftime('%Y-%m-%d')
rescue ArgumentError
  nil
end

json.url @resource[:url]
json.title strip_tags(@resource[:title])
json.description truncate(strip_tags(@resource[:description]), length: 200, separator: ' ')
json.images @resource[:images]
json.logo @resource[:logo]
json.type @resource[:type]
json.media_type @resource[:media_type]
json.more_link_text @resource[:more_link_text]
json.count_label @resource[:count_label]
json.date date
json.attribution @resource[:attribution]
