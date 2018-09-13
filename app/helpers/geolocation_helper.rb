# frozen_string_literal: true

module GeolocationHelper
  def format_latitude(latitude)
    point = latitude.to_f.positive? ? :north : :south
    format_lat_or_long(latitude, point)
  end

  def format_longitude(longitude)
    point = longitude.to_f.positive? ? :east : :west
    format_lat_or_long(longitude, point)
  end

  def format_lat_or_long(lat_or_long, point)
    format("%{distance} ° %{direction}",
           distance: lat_or_long.to_s,
           direction: I18n.t(point, scope: 'site.object.points'))
  end
end
