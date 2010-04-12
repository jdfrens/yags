Feature: managing courses
  As an instructor
  I want to see the courses I'm teaching
  So that I can assess my students' work

  Scenario: listing courses
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

  Scenario: delete a course
    Given an instructor "mendel"
    And a course "BIO 143a" for "mendel"
    When I login as "mendel"
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
    When I login as "mendel"
    And I am on the courses page
    And I follow "See BIO 143a"
    Then I should see "student01"
    And I should see "student02"
    And I should see "student03"
    And I should not see "student66"
