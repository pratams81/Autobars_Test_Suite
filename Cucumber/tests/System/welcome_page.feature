Feature: When I login in the Autobars app then I am able to navigate to and from welcome landing page

  Background: Start app
    Given app is open and configured for system tests
    And login screen is displayed with title "Welcome to the Valuation Office Agency"
    When I login with "<username>" and "<password>"
    Then "<screen_name>" screen is displayed
    Examples:
      | username | password     | screen_name            |
      | ealing   | japanesenods | Welcome Ealing Council |

  Scenario: I should be able to see correct icon on the welcome page


    Scenario: I should be able to view and click "Council Tax" link on the welcome page

      Scenario: I should be able to logout from welcome screen


        Scenario: I should not be able to navigate non domestic rates on the welcome screen