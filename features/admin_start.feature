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

  Scenario: list mendel's courses
    Given an instructor "mendel"
    And a course "BIO 143a" for "mendel"
    And a course "BIO 143d" for "mendel"
    And a course "BIO 143q" for "mendel"
    When I login as "mendel"
    And I am on the lab page
    And I follow "List Courses"
    Then I should see "BIO 143a"
    And I should see "BIO 143d"
    And I should see "BIO 143q"
