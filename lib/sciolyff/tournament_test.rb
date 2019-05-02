# frozen_string_literal: true

require 'minitest/test'
require 'set'

# Tests that also serve as the specification for the sciolyff file format
#
class TournamentTest < Minitest::Test
  def setup
    @tournament = $rep['Tournament']
  end

  def test_has_tournament_info
    refute_nil @tournament['name']
    refute_nil @tournament['level']
    refute_nil @tournament['division']
    refute_nil @tournament['year']
    refute_nil @tournament['date']
  end

  def test_does_not_have_extra_tournament_info
    info = Set.new %w[name level division year date]
    assert Set.new(@tournament.keys).subset? info
  end

  def test_has_valid_tournament_name
    assert_instance_of String, @tournament['name']
  end

  def test_has_valid_tournament_level
    level = @tournament['level']
    assert_includes %w[Invitational Regionals States Nationals], level
  end

  def test_has_valid_tournament_division
    assert_includes %w[A B C], @tournament['division']
  end

  def test_has_valid_tournament_year
    assert_instance_of Integer, @tournament['year']
  end

  def test_has_valid_tournament_date
    assert_instance_of Date, @tournament['date']
  end
end
