Feature: Login
  As a User
  I want to login to Autobars
  When I enter an invalid password then I should be prompted with an error message

  Background: Start app
    Given app is open and configured for system tests
    And login screen is displayed with title "Welcome to the Valuation Office Agency"


  Scenario Outline: Successful Login
    When I login with "<username>" and "<password>"
    Then "<screen_name>" screen is displayed
    Examples:
      | username | password     | screen_name            |
      | ealing   | japanesenods | Welcome Ealing Council |


  Scenario Outline: Unsuccessful Login with invalid password
    When I login with "<username>" and "<password>"
    Then login screen is displayed with title "<title>"
    Then login should be failed
    Then "<error>" error message is displayed on the login screen
    Examples:
      | username | password      | title                                  | error                                                                                 |
      | ealing   | japanesenods1 | Welcome to the Valuation Office Agency | Your username or password have not been recognised. Please verify them and try again. |


  Scenario: When I select "Remember me" then I should be able to login without a user name and password the second time
    When I enter "ealing" in username
      And I enter "japanesenods" in password
      And I click "Remember me" button on login screen
      And I click "Sign In" button on login screen
    Then "Welcome Ealing Council" screen is displayed
    When I click "logout" on welcome page
    Then login screen is displayed with title "Welcome to the Valuation Office Agency"
    When I click "Sign In" button on login screen
    Then "Welcome Ealing Council" screen is displayed