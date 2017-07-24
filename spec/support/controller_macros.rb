# frozen_string_literal: true

module ControllerMacros
  def login_admin
    before(:each) do
      @request.env['devise.mapping'] = Devise.mappings[:admin]
      sign_in users(:admin)
    end
  end

  def login_editor
    before(:each) do
      @request.env['devise.mapping'] = Devise.mappings[:editor]
      sign_in users(:editor)
    end
  end

  def login_user
    before(:each) do
      @request.env['devise.mapping'] = Devise.mappings[:user]
      sign_in users(:user)
    end
  end

  def login_guest
    before(:each) do
      @request.env['devise.mapping'] = Devise.mappings[:guest]
      sign_in users(:guest)
    end
  end
end

