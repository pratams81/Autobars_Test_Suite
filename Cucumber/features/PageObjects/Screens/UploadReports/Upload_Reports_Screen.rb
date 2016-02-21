# encoding: UTF-8
# Author: Elin Lloyd

# helper methods for login screen
class Upload_Reports_Screen
  def initialize(browser, app_type)
    @browser = browser
    @app_type = app_type
  end

  def displayed?
    begin
      @browser.find_element(:tag_name, 'h1').text == "Upload your Council Tax Reports"
      return true
    rescue
      return false
    end
  end

  def title
    return @browser.find_element(:tag_name, 'h1')
  end

  def attach_files
    return @browser.find_elements(:tag_name, 'u')
  end

  def submit_button
    return @browser.find_elements(:class, 'button')
  end

  end