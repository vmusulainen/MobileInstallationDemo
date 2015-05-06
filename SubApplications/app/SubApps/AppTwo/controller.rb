require 'rho/rhocontroller'
require 'helpers/application_helper'
require 'helpers/browser_helper'

class AppOneController < Rho::RhoController
  include ApplicationHelper
  include BrowserHelper

  def index
    render
  end

  def switchToHostApp
    Rho::NativeTabbar.switchTab(0)
  end

end
