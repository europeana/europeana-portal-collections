##
# User settings controller
class SettingsController < ApplicationController
  include Europeana::Styleguide

  def language
    respond_to do |format|
      format.html
    end
  end
end
