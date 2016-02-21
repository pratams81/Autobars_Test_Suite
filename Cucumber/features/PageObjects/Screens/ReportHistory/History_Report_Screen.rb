# encoding: UTF-8
# Author: Elin Lloyd

# helper methods for login screen
class Report_Screen
  def initialize(browser, app_type)
    @browser = browser
    @app_type = app_type
  end

  def displayed?
    begin
      @browser.find_element(:css, "Today's Submissions")
      return true
    rescue
      return false
    end
  end

  def login_title
    return @browser.find_element(:class, 'heading-large')
  end

  def pass_fail_heading
    return @browser.find_element(:class, 'heading-medium')
  end


  def pass_text
    return pass_fail_heading.find_element(:tag_name, 'li')
  end

  def failed_reports_list
    return @browser.find_element(:class, 'heading-small')
  end

  def error_message
    return @browser.find_element(:class, 'error-message')
  end

  end