module TimeDateHelper
  def unix_time_to_local(unix_time)
    utc_date_time = Time.at(unix_time / 1000).utc.to_datetime
    Time.zone.utc_to_local(utc_date_time)
  end
end
