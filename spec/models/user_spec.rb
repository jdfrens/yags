require File.dirname(__FILE__) + '/../spec_helper'

describe User do

  it { should have_many :vials }
  it { should have_many(:shelves).dependent(:destroy) }
  it { should have_many(:character_preferences).dependent(:destroy) }
  it { should have_one(:basic_preference).dependent(:destroy) }
  it { should have_many(:phenotype_alternates).dependent(:destroy) }
  it { should have_many(:instructs).dependent(:destroy) }
  it { should have_many(:owned_scenarios).dependent(:destroy) }
  it { should belong_to(:enrolled_in) }

  describe "batch creating students" do
    it "should create a student" do
      student_csv = "last, first, email@web.site"

      count = User.batch_create!(student_csv, "password", stub_model(Course))

      count.should == 1
      user = User.find_by_username("email")
      user.first_name.should == "first"
      user.last_name.should == "last"
      user.password_hash.should == User.hash_password("password")
    end

    it "should trim off whitespace" do
      student_csv = %q{
        last, first, email@web.site
      }

      count = User.batch_create!(student_csv, "password", stub_model(Course))

      count.should == 1
      User.find_by_username("email").should_not be_nil
    end

    it "should create a lot of students" do
      student_csv = %Q{last, first, email@web.site
        VanderName, John, jov31@calvin.foo
        A, B, C123@somewhere.edu
        another, new, student@calvin.foo}

      count = User.batch_create!(student_csv, "password", stub_model(Course))

      count.should == 4
      User.find_by_username("email").should_not be_nil
      User.find_by_username("jov31").should_not be_nil
      User.find_by_username("C123").should_not be_nil
      User.find_by_username("student").should_not be_nil
    end
  end
end

class UserTest < ActiveSupport::TestCase

  fixtures :all

  def test_solutions
    users(:randy).solutions.should == []
    users(:jeremy).solutions.should include(solutions(:jeremy_solves_2))
    users(:steve).solutions.should include(*solutions(:steve_solves_1, :steve_solves_8))
  end

  def test_solutions_as_hash
    assert_equal({}, users(:randy).solutions_as_hash)
    assert_equal({ 2 => solutions(:jeremy_solves_2) }, users(:jeremy).solutions_as_hash)
    assert_equal({ 1 => solutions(:steve_solves_1), 8 => solutions(:steve_solves_8) }, users(:steve).solutions_as_hash)
    assert_equal solutions(:steve_solves_8), users(:steve).solutions_as_hash[8]
    assert_nil users(:steve).solutions_as_hash[5]
    assert_nil users(:steve).solutions_as_hash[9]
  end

  def test_owns?
    assert  users(:jeremy).owns?(vials(:destroyable_vial))
    assert !users(:steve).owns?(vials(:destroyable_vial))
    assert !users(:jeremy).owns?(shelves(:steve_bench_shelf))
    assert  users(:steve).owns?(shelves(:steve_bench_shelf))
  end

  def test_hidden_characters
    assert_equal [:"eye color", :wings, :antenna], users(:randy).hidden_characters
    assert_equal [:legs, :antenna, :seizure], users(:jeremy).hidden_characters
    assert_equal [:seizure], users(:steve).hidden_characters
  end

  def test_visible_characters
    assert_equal [:sex, :legs, :seizure], users(:randy).visible_characters
    assert_equal [:sex, :"eye color", :wings], users(:jeremy).visible_characters
    assert_equal [:sex, :"eye color", :wings, :legs, :antenna], users(:steve).visible_characters

    assert_equal [], users(:randy).visible_characters([])
    assert_equal [], users(:jeremy).visible_characters([])
    assert_equal [], users(:steve).visible_characters([])

    assert_equal [:telekinesis, :legs], users(:randy).visible_characters([:telekinesis, :wings, :legs])
    assert_equal [:telekinesis, :wings], users(:jeremy).visible_characters([:telekinesis, :wings, :legs])
  end

  def test_visible_huh
    assert users(:randy).visible?(:sex)
    assert !users(:randy).visible?(:wings)
    assert !users(:randy).visible?(:devil_and_angel_on_shoulders)

    assert users(:jeremy).visible?(:wings)
    assert !users(:jeremy).visible?(:legs)
    assert !users(:jeremy).visible?(:internal_bleeding)
  end

  def test_student?
    assert !users(:mendel).student?
    assert !users(:calvin).student?
    assert users(:steve).student?
  end

  def test_instructor?
    assert users(:mendel).instructor?
    assert !users(:calvin).instructor?
    assert !users(:steve).instructor?
  end

  def test_admin?
    assert !users(:mendel).admin?
    assert users(:calvin).admin?
    assert !users(:steve).admin?
  end

  def test_students
    assert_equal [users(:jeremy), users(:randy), users(:keith)], users(:mendel).students
    assert_equal [users(:steve)], users(:darwin).students
    assert_equal [], users(:calvin).students
    assert_equal [], users(:steve).students
  end

  def test_has_authority_over
    assert users(:mendel).has_authority_over(users(:jeremy))
    assert users(:mendel).has_authority_over(users(:randy))
    assert users(:darwin).has_authority_over(users(:steve))
    assert users(:calvin).has_authority_over(users(:darwin))
    assert users(:calvin).has_authority_over(users(:steve))
    assert users(:steve).has_authority_over(users(:steve))
    assert users(:mendel).has_authority_over(users(:mendel))
    assert users(:calvin).has_authority_over(users(:calvin))

    assert !users(:mendel).has_authority_over(users(:steve))
    assert !users(:darwin).has_authority_over(users(:randy))
    assert !users(:darwin).has_authority_over(users(:mendel))
    assert !users(:steve).has_authority_over(users(:darwin))
    assert !users(:randy).has_authority_over(users(:jeremy))
    assert !users(:mendel).has_authority_over(users(:calvin))
  end

  def test_current_shelves
    assert_raise Exception do
      users(:keith).current_shelves
    end
    assert_equal ["jeremy bench", "jeremy stock"], users(:jeremy).current_shelves.map { |r| r.label }.sort
    assert_equal [ "Trash", "steve bench", "steve stock"], users(:steve).current_shelves.map { |r| r.label }.sort
    assert_raise Exception do
      users(:mendel).current_shelves
    end
    assert_raise Exception do
      users(:calvin).current_shelves
    end
  end

  def test_current_shelves_without_trash
    assert_raise Exception do
      users(:keith).current_shelves_without_trash
    end
    assert_equal ["jeremy bench", "jeremy stock"], users(:jeremy).current_shelves_without_trash.map{ |r| r.label }.sort
    assert_equal ["steve bench", "steve stock"], users(:steve).current_shelves_without_trash.map { |r| r.label }.sort
    assert_raise Exception do
      users(:mendel).current_shelves_without_trash
    end
    assert_raise Exception do
      users(:calvin).current_shelves_without_trash
    end
  end

  def test_trash_shelf
    assert_raise Exception do
      users(:keith).trash_shelf
    end
    assert_equal shelves(:steve_trash_shelf), users(:steve).trash_shelf
    assert_raise Exception do
      users(:mendel).trash_shelf
    end
    assert_raise Exception do
      users(:calvin).trash_shelf
    end
  end

  def test_current_vials
    assert_raise Exception do
      users(:keith).current_vials
    end
    assert_equal ["Another vial", "Destroyable vial"], users(:jeremy).current_vials.map { |r| r.label }.sort
    assert_equal ["Empty vial", "First vial", "Multiple fly vial", "Parents vial", "Single fly vial"],
                 users(:steve).current_vials.map { |r| r.label }.sort
    assert_raise Exception do
      users(:mendel).current_vials
    end
    assert_raise Exception do
      users(:calvin).current_vials
    end
  end

  def test_add_default_shelves_for_current_scenario
    assert users(:randy).current_shelves.select{ |r| r.label == "Trash" }.empty?
    assert users(:randy).current_shelves.select{ |r| r.label == "Default" }.empty?
    users(:randy).add_default_shelves_for_current_scenario
    assert_equal 1, users(:randy).current_shelves.select{ |r| r.label == "Trash" }.size
    assert users(:randy).current_shelves.select{ |r| r.label == "Default" }.empty?

    assert users(:keith).shelves.select{ |r| r.label == "Trash" }.empty?
    assert users(:keith).shelves.select{ |r| r.label == "Default" }.empty?
    users(:keith).current_scenario_id = 4
    users(:keith).add_default_shelves_for_current_scenario
    assert_equal 1, users(:keith).current_shelves.select{ |r| r.label == "Trash" }.size
    assert_equal 1, users(:keith).current_shelves.select{ |r| r.label == "Default" }.size
  end

  def test_row
    assert_equal "wings", users(:jeremy).row
    assert_nil users(:steve).row
  end

  def test_column
    assert_equal "eye color", users(:jeremy).column
    assert_nil users(:steve).column
  end

  def test_current_scenario_id=
    users(:steve).current_scenario_id = 2
    users(:steve).reload
    assert_equal Scenario.find(2), users(:steve).current_scenario
    users(:steve).current_scenario_id = 1
    users(:steve).reload
    assert_equal Scenario.find(1), users(:steve).current_scenario
  end

  def test_set_scenario_to
    users(:steve).set_scenario_to(2, CookedNumberGenerator.new([1, 1]))
    users(:steve).reload
    assert_equal Scenario.find(2), users(:steve).current_scenario
    assert_equal :turquoise, users(:steve).vials.first.renamed_phenotype(:"eye color", :red)
    assert_equal :beige, users(:steve).vials.first.renamed_phenotype(:"eye color", :white)
    assert_equal ["beige", "turquoise"], users(:steve).phenotype_alternates.map { |pa| pa.renamed_phenotype }
    users(:steve).set_scenario_to(4)
    users(:steve).reload
    assert_equal Scenario.find(4), users(:steve).current_scenario
    assert_equal :red, users(:steve).vials.first.renamed_phenotype(:"eye color", :red)
    assert_equal :white, users(:steve).vials.first.renamed_phenotype(:"eye color", :white)
    users(:steve).set_scenario_to(2, CookedNumberGenerator.new([0, 4]))
    users(:steve).reload
    assert_equal Scenario.find(2), users(:steve).current_scenario
    assert_equal ["beige", "turquoise"], users(:steve).phenotype_alternates.map { |pa| pa.renamed_phenotype }
    # unchanged
  end

  def test_set_scenario_to_doesnt_assign_red_and_white_to_blue_and_blue
    users(:steve).set_scenario_to(2, CookedNumberGenerator.new([3, 3]))
    users(:steve).reload
    assert_equal Scenario.find(2), users(:steve).current_scenario
    assert_equal ["blue", "green"], users(:steve).phenotype_alternates.map { |pa| pa.renamed_phenotype }
  end

  def test_set_scenario_to_validates_scenario_id
    users(:steve).set_scenario_to(1)
    users(:steve).reload
    assert_equal Scenario.find(4), users(:steve).current_scenario
  end

  def test_set_scenario_to_adds_default_shelves
    assert users(:keith).shelves.select{ |r| r.label == "Trash" }.empty?
    assert users(:keith).shelves.select{ |r| r.label == "Default" }.empty?
    users(:keith).set_scenario_to(4)
    assert_equal 1, users(:keith).current_shelves.select{ |r| r.label == "Trash" }.size
    assert_equal 1, users(:keith).current_shelves.select{ |r| r.label == "Default" }.size
  end

  def test_set_table_preference
    assert_equal "wings", users(:jeremy).basic_preference.row
    assert_equal "eye color", users(:jeremy).basic_preference.column
    users(:jeremy).set_table_preference "antenna", "wings"
    assert_equal "antenna", users(:jeremy).basic_preference.row
    assert_equal "wings", users(:jeremy).basic_preference.column

    assert_raise Exception do
      users(:keith).set_table_preference "antenna", "wings"
    end
    assert_raise Exception do
      users(:calvin).set_table_preference "antenna", "wings"
    end
    assert_raise Exception do
      users(:mendel).set_table_preference "antenna", "wings"
    end
  end

  def test_set_character_preferences
    steve = users(:steve)
    steve.set_character_preferences(Species.singleton.characters, ["sex", "antenna"])
    steve.reload
    assert_equal [:sex, :antenna], steve.visible_characters
    steve.set_character_preferences(Species.singleton.characters, ["wings", "antenna", "hooves"])
    steve.reload
    assert_equal [:wings, :antenna], steve.visible_characters
  end

  def test_set_character_preferences_resets_table_preferences
    jeremy = users(:jeremy)
    jeremy.set_character_preferences(Species.singleton.characters, ["sex", "eye color"])
    jeremy.reload
    assert_equal [:sex, :"eye color"], jeremy.visible_characters
    assert_nil jeremy.basic_preference.row
    assert_nil jeremy.basic_preference.column
  end

end
