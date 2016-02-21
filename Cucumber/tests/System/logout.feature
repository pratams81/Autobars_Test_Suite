Feature: Logout
  As a user - I want to be able to logout from the application
  After logging out, revisiting the app should allow me to sign in again

  Background: App opened
    Given app is open and configured for system tests
      And app is configured for cwmciwla lab
      And app is started

  Scenario: The logout button is present in settings
    When login screen is displayed
      And "nmp@nagra.com" has logged into JoinIn with "nmp"
      And browse screen is displayed
    # Opens settings
    When settings dialog is opened from browse screen
    Then the logout button is visible

  @desktop_only
  Scenario: Pressing the logout button returns the user to the login page on desktop
    When login screen is displayed
      And "nmp@nagra.com" has logged into JoinIn with "nmp"
      And browse screen is displayed
    # Opens settings
    When settings dialog is opened from browse screen
      And the logout button is clicked
      And app is started
    Then login screen is displayed

  @desktop_only
  Scenario: Username is retained after logout
    When login screen is displayed
      And "nmp@nagra.com" has logged into JoinIn with "nmp"
      And browse screen is displayed
    When settings dialog is opened from browse screen
      And the logout button is clicked
      And app is started
    Then login screen is displayed
      And username field contains "nmp@nagra.com"
      And password field contains ""


  # TODO: Could better verify behaviour after
  @phone_and_tablet_only
  Scenario: Pressing the logout button exits the app on devices
    When app is configured with a fake quit method
      And login screen is displayed
      And "nmp@nagra.com" has logged into JoinIn with "nmp"
    Then browse screen is displayed
    When settings dialog is opened from browse screen
      And the logout button is clicked
    Then the application has been quit
    When the application is reloaded
      And app is started
    Then login screen is displayed


  @desktop_only
  Scenario: Pressing the logout button retains user settings
    When login screen is displayed
      And "nmp@nagra.com" has logged into JoinIn with "nmp"
    Then browse screen is displayed
    When parental control dialog is opened from browse screen
      And rating 12 is selected
      And "nmp" is entered into dialog password field
      And submit is clicked in the password dialog
      And settings dialog is opened from browse screen
      And the logout button is clicked
      And app is configured for cwmciwla lab
      And app is started
    Then login screen is displayed
    When "" has logged into JoinIn with "nmp"
    Then browse screen is displayed
      And rating is set to 12

  # HACK: Fix up the state for the following stateful tests
  Scenario: Basic login
    When login screen is displayed
      And "nmp@nagra.com" has logged into JoinIn with "nmp"
      And browse screen is displayed
