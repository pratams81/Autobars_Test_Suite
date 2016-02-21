# encoding: UTF-8
# Author: Elin Lloyd

# helper methods for login screen
class Submission_Progress_Screen
  def initialize(browser, app_type)
    @browser = browser
    @app_type = app_type
  end

  def displayed?
    begin
      @browser.find_element(:tag_name, 'h1').text == "Your submission has completed"
      return true
    rescue
      return false
    end
  end

  def title
    return @browser.find_element(:tag_name, 'h1')
  end

def completed_check
  return @browser.find_element(:class, 'complete')
  end

  def successful_nos
  return @browser.find_element(:id, 'success')
  end

  def total_nos
  return @browser.find_element(:id, 'total')
  end

  def failed
  return @browser.find_element(:id, 'failed')
    end

  def ok_button
    return @browser.find_element(:id, 'button')
  end

  def failed_link
    return @browser.find_element(:css, 'progress/failed')
  end

  end