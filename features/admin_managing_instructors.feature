Feature: managing instructor
  As an administrator
  I want to manage the instructors
  So that they can use the system

  Scenario: adding an instructor
    Given an admin "darwin"
    When I log in as "darwin"
    And I am on the users page
    And I follow "Add an Instructor"
    And I fill in the following:
      | Username              | dawkins             |
      | Email address         | dawkins@example.com |
      | Password              | secret              |
      | Password Confirmation | secret              |
    And I press "Add Instructor"
    Then I should see "Listing All Users"
    And I should see "dawkins (instructor)"
