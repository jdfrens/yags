Feature: managing courses
  As an instructor
  I want to see the courses I'm teaching
  So that I can assess my students' work

  Scenario: listing courses
    Given an instructor "mendel"
    And a course "BIO 143a" for "mendel"
    And a course "BIO 143d" for "mendel"
    And a course "BIO 143q" for "mendel"
    When I log in as "mendel"
    And I am on the lab page
    And I follow "List Courses"
    Then I should see "BIO 143a"
    And I should see "BIO 143d"
    And I should see "BIO 143q"

  Scenario: listing no courses and starting a new course
    Given an instructor "mendel"
    When I log in as "mendel"
    And I am on the courses page
    And I follow "Create a new course"
    Then I should see "Add Course"

  Scenario: add a course
    Given an instructor "mendel"
    When I log in as "mendel"
    And I am on the lab page
    And I follow "Add a course"
    And I fill in "Name" with "BIO 338"
    And I press "Add Course"
    Then I should be on the courses page
    And I should see "BIO 338"

  Scenario: delete a course
    Given an instructor "mendel"
    And a course "BIO 143a" for "mendel"
    When I log in as "mendel"
    And I am on the courses page
    Then I should see "BIO 143a"
    When I follow "Delete BIO 143a"
    Then I should be on the courses page
    And I should not see "BIO 143a"

  Scenario: see students in course
    Given an instructor "mendel"
    And a course "BIO 143a" for "mendel"
    And a student "student01" in "BIO 143a"
    And a student "student02" in "BIO 143a"
    And a student "student03" in "BIO 143a"
    And a student "student66"
    When I log in as "mendel"
    And I am on the courses page
    And I follow "See BIO 143a"
    Then I should see "student01"
    And I should see "student02"
    And I should see "student03"
    And I should not see "student66"

  Scenario: add a student
    Given an instructor "mendel"
    And a course "BIO 143a" for "mendel"
    And a course "BIO 143b" for "mendel"
    When I log in as "mendel"
    And I am on the lab page
    And I follow "Add a student"
    Then I should see "Add Student"
    When I fill in the following:
      | Username              | studentABC             |
      | First name            | Firsty                 |
      | Last name             | Lasty                  |
      | Email address         | studentABC@example.com |
      | Password              | foobar                 |
      | Password confirmation | foobar                 |
    And I select "BIO 143b" from "Course"
    And I press "Add Student"
    Then I should see "Listing All Users"
    And I should see "studentABC (student)"

  Scenario: add multiple students
    Given an instructor "mendel"
    And a course "BIO 143" for "mendel"
    When I log in as "mendel"
    And I am on the lab page
    And I follow "Batch add students"
    And I select "BIO 143" from "Course"
    And I fill in "Password" with "secret"
    And I fill in "Student Information" with "Darwin,Charles,cdarwin@example.com"
    And I press "Add Students"
    Then I should see "1 students added!"
    And I should see "cdarwin"
