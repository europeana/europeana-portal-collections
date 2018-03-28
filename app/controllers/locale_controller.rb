# frozen_string_literal: true

class LocaleController < ApplicationController
  def index
    redirect_to_home
  end

  def show
    redirect_to add_locale_to_path(request.original_fullpath, I18n.locale)
  end

  def update
    redirect_to sub_locale_in_path(local_redirect || home_path, params[:l], I18n.locale)
  end

  private

  def local_redirect
    @local_redirect ||= begin
      if params[:redirect]&.is_a?(String) && params[:redirect] =~ %r{\A/}
        params[:redirect]
      end
    end
  end

  def relative_url_root
    @relative_url_root ||= Europeana::Portal::Application.config.relative_url_root
  end

  def sub_locale_in_path(path, locale, old_locale)
    if relative_url_root.present?
      path.sub(/\A#{relative_url_root}\/#{old_locale}/, "#{relative_url_root}/#{locale}")
    else
      path.sub(/\A\/#{old_locale}/, "/#{locale}")
    end
  end

  def add_locale_to_path(path, locale)
    if relative_url_root.present?
      path.sub(/\A#{relative_url_root}/, "#{relative_url_root}/#{locale}")
    elsif path == '/'
      "/#{locale}"
    else
      "/#{locale}#{path}"
    end
  end
end
