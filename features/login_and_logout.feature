Feature: Logging in and out of the app
  As a user
  I want to log in or log out
  So that I can access my resources and yet keep them protected

  Scenario: log in as an instructor
    Given only the following users
      | username | password | group      |
      | mendel   | peas     | instructor |
    When I go to the login page
    And I fill in "Username" with "mendel"
    And I fill in "Password" with "peas"
    And I press "Login"
    Then I should not see "Invalid login credentials"
    And I should be on the lab page

  Scenario: log in as an admin
    Given only the following users
      | username | password | group |
      | darwin   | finches  | admin |
    When I go to the login page
    And I fill in "Username" with "darwin"
    And I fill in "Password" with "finches"
    And I press "Login"
    Then I should not see "Invalid login credentials"
    And I should be on the users page
