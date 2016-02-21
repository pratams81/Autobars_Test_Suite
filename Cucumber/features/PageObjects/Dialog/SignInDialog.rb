require_relative '../Screens/Header/Header.rb'

class SignInDialog < Header

  def dialog
    dialogs = @browser.find_elements(:class, 'dialog')
    return dialogs.last
  end

  def dialog_title
    return dialog.find_element(:tag_name, 'h2')
  end


  def dialog_username
    return dialog.find_element(:name, 'username')
  end

  def dialog_password
    return dialog.find_element(:name, 'password')
  end

  def dialog_submit_button
    return dialog.find_element(:css, ".dialog-button[data-attribute='sign-in']")
  end

  def dialog_cancel_button
    return dialog.find_element(:css, ".dialog-button[data-attribute='cancel']")
  end

  def dialog_username_warning
    return dialog.dialog_username.find_element(:css, "dialog-input required")
  end
  
  def dialog_ok_button
    return dialog.find_element(:css, ".dialog-button[data-attribute='close']")
  end

end