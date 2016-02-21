require_relative '../Screens/Header/Header.rb'

# helper methods for ui dialogs (popups, mobile menu)
class Dialog < Header
  def initialize(browser, app_type, _env = 'ott.nagra.com')
    super(browser, app_type)
    self.class.send(:include, DialogPhone) if app_type == 'Phone'
  end

  # Returns true is a dialog is currently being displayed
  def is_displayed
    dialog.displayed?
    rescue Selenium::WebDriver::Error::StaleElementReferenceError
      false
    # This is needed as appium does not return a stale element reference error
    rescue Selenium::WebDriver::Error::WebDriverError
      false
    rescue NoMethodError
      false
  end

  # Set dialog the 1st available dialog (i.e. the one on top)
  def dialog
    dialogs = @browser.find_elements(:class, 'dialog')
    return dialogs.last
  end

  # Returns the 1st modal dialog element
  def dialog_modal
    @browser.find_element(:class, 'dialog-overlay-modal')
  end

  # Returns the category menu element
  def categories_menu
    @browser.find_element(:id, 'categoryMenu')
  end

  # Returns the list elements in the dialog
  def get_dialog_list
    dialog.find_elements(:css, 'li.dialog-list')
  end

  # Returns the text in the text elements in the dialog
  def get_dialog_text
    dialog_text = []
    dialog.find_elements(:class, 'dialog-text').each do |item|
      dialog_text.push(item.text)
    end
    dialog.find_elements(:class, 'dialog-text-settings').each do |item|
      dialog_text.push(item.text)
    end
    dialog_text
  end

  # Returns the button text of buttons in the dialog
  def get_dialog_buttons_text
    dialog_button_text = []
    get_dialog_buttons.each do |item|
      dialog_button_text.push(item.text)
    end
    dialog_button_text
  end

  # Returns the text in the dialog header/title
  def get_dialog_title
    dialog.find_element(:class, 'dialog-title-bar').text
  end

  # Returns the button text of buttons in the dialog
  def get_dialog_textfields
    textfields = []
    dialog.find_elements(:class, 'dialog-input').each do |item|
      textfields.push(item) if (item.attribute('type') == 'text') || (item.attribute('type') == 'password')
    end
    textfields
  end

  # Returns all the textfield elements
  def get_dialog_textfield(input_name)
    return dialog.find_element(:name, input_name)
  end

  # Returns the selected list element in the dialog
  def get_selected_dialog_list_item
    selected_item = nil
    get_dialog_list.each do |item|
      if item.find_element(:class, 'dialog-input').attribute('checked')
        selected_item = item
        break
      end
    end
    selected_item
  end

  # Returns the button elements in the dialog
  def get_dialog_buttons
    dialog.find_elements(:class, 'dialog-button')
  end

  # Return the password field element in the dialog (assumed there is only ever one password field in a dialog)
  def get_dialog_password_field
    dialog.find_element(:name, 'password')
  end

  # Returns the place holder text of a password field element in the dialog
  def get_dialog_password_field_placeholder
    get_dialog_password_field.attribute('placeholder')
  end

  # Returns input text element in the dialog
  def get_dialog_input_fields
    dialog.find_elements(:class, 'dialog-input')
  end

  # Click a option (in the provided location) in the audio language list
  def click_audio_language_setting(listLocation)
    dialog.find_elements(:class, 'dialog-list')[listLocation].click
  end

  # Clicks the submit button in the dialog (assumed there is only ever one submit button in a dialog)
  def click_submit
    get_dialog_buttons.each do |button|
      if button.attribute('data-attribute') == 'submit'
        button.click
        break
      end
    end
    sleep(10)
  end

  def dialog_list_ul
    return dialog.find_element(:css, 'ul.dialog-list')
  end

  def option_list(option_name)
    return dialog_list_ul.find_elements(:css, 'li')
  end

  def settings_option(option_name)
    return option_list(option_name).detect { |li| li.attribute('data-attribute') == option_name }
  end

  # Clicks the button with the given data-attribute
  def click_button(button_text)
    get_dialog_buttons.each do |button|
      if button.attribute('data-attribute') == button_text
        button.click
        break
      end
    end
  end

  # Click a dialog list item with the matching name
  def click_dialog_item(itemName)
    get_dialog_list.each do |item|
      if item.text == itemName
        item.click
        break
      end
    end
  end

  # Click a dialog list item with the matching name
  def click_checkbox_item(itemName)
    click_dialog_item(itemName)
  end

  # Close the dialog with the provided action
  def close_dialog(action)
    buttons = get_dialog_buttons
    if action == 'Back'
      buttons.each do |button|
        button.click if button.text == 'Back'
      end
    elsif action == 'Tap'
      # Should work for FF/IE
      @browser.find_element(:class, 'dialog-overlay-modal').click
      # Should work for Chrome
      @browser.find_element(:id, 'masterContainer').click
    elsif action == 'Menu'
      click_mobile_menu
    elsif action == 'Cancel'
      buttons.each do |button|
        button.click if button.attribute('data-attribute') == 'cancel' || button.attribute('data-attribute') == 'close'
      end
    else
      fail "Close Action was not recognised -  valid actions are: Back, Menu, Cancel, Tap. \n  Action tried: #{action}"
    end
  end

  protected


end

# Helper methods for specifically for phone dialogs
module DialogPhone
  # Returns the list elements in the dialog
  def get_dialog_list
    dialog.find_elements(:class, 'dialog-list-no-bg')
  end

  def get_dialog_title
    dialog.find_element(:class, 'dialog-title-bar').text rescue get_dialog_fullscreen_title
  end

  def get_dialog_fullscreen_title
    dialog.find_element(:class, 'dialog-fullscreen-title').text rescue header_text
  end

  # This is required as mixin inheritance is broken in ruby - fixed in ruby 2.0 by using prepend rather than include
  def self.append_features(mod)
    instance_methods(false).each do |method|
      mod.send(:remove_method, method) if mod.instance_methods(false).include?(method)
    end
    super
  end

  protected

  # Set dialog the 1st available dialog (i.e. the one on top)
  def dialog
    dialog_elems = @browser.find_elements(:class, 'dialog-overlay')
    if dialog_elems.length > 0
      return dialog_elems.last
    else
      return @browser.find_elements(:class, 'dialog-overlay-settings').last
    end
  end
end
