# encoding: UTF-8
# Author: Elin Lloyd

# helper methods for login screen
class Welcome_Screen
  def initialize(browser, app_type)
    @browser = browser
    @app_type = app_type
  end

  def displayed?
    begin
      @browser.find_element(:css, 'Autobars')
      return true
    rescue
      return false
    end
  end

  def login_title
    return @browser.find_element(:tag_name, 'h1')
  end

  def logout
    return @browser.find_element(:class, 'logout')
  end

  def council_tax
    return @browser.find_element(:css, 'counciltax')
  end

  def non_domestic_rates
    return @browser.find_element(:css, 'ndr')
  end

  def image
    return @browser.find_element(:tag_name, 'img')
  end

  def img_src
    return image.attribute('src')
  end

  def home_link
    return @browser.find_element(:css, '/')
  end

end