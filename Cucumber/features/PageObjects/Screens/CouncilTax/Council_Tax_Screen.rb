# encoding: UTF-8
# Author: Elin Lloyd

# helper methods for login screen
class Council_Tax_Screen
  def initialize(browser, app_type)
    @browser = browser
    @app_type = app_type
  end

  def displayed?
    begin
      @browser.find_element(:tag_name, 'h1').text == "Council Tax"
      return true
    rescue
      return false
    end
  end

  def title
    return @browser.find_element(:tag_name, 'h1')
  end

  def upload_reports
    return @browser.find_element(:css, "counciltax/submit")
  end

  def previous_submissions
    return @browser.find_element(:css, "counciltax/history")
  end

end
