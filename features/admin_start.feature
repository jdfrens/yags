Feature: getting started
  As an administrator
  I want to start a YAGS app
  So that my instructors can teach genetics

  Scenario: log in as mendel
    Given only the following users
      | username | password | group      |
      | mendel   | peas     | instructor |
    When I go to the login page
    And I fill in "Username" with "mendel"
    And I fill in "Password" with "peas"
    And I press "Login"
    Then I should not see "Invalid login credentials"
    And I should be on the lab page
