# encoding: UTF-8
# Author: Elin Lloyd

# helper methods for login screen
class SubmissionReportScreen
  def initialize(browser, app_type)
    @browser = browser
    @app_type = app_type
  end

  def displayed?
    begin
      @browser.find_element(:css, 'Reports Submission History')
      return true
    rescue
      return false
    end
  end

  def login_title
    return @browser.find_element(:class, 'heading-large')
  end

  def download_pdf
    return @browser.find_element(:css, 'Download a receipt of your submission [PDF]')
  end

  def report_today
    return @browser.find_element(:css, "history/detail?days=1")
  end

  def report_7day
    return @browser.find_element(:css, "history/detail?days=7")
  end

  def report_30day
    return @browser.find_element(:css, "history/detail?days=30")
  end

  end