# frozen_string_literal: true

require 'minitest/test'
require 'set'

module SciolyFF
  # Tests that also serve as the specification for the sciolyff file format
  #
  class TournamentTest < Minitest::Test
    def setup
      @tournament = SciolyFF.rep['Tournament']
      skip if @tournament.nil?
    end

    def test_has_info
      refute_nil @tournament['name']
      refute_nil @tournament['level']
      refute_nil @tournament['division']
      refute_nil @tournament['year']
      refute_nil @tournament['date']
    end

    def test_does_not_have_extra_info
      info = Set.new %w[name level division year date]
      assert Set.new(@tournament.keys).subset? info
    end

    def test_has_valid_name
      assert_instance_of String, @tournament['name']
    end

    def test_has_valid_level
      level = @tournament['level']
      assert_includes %w[Invitational Regionals States Nationals], level
    end

    def test_has_valid_division
      assert_includes %w[A B C], @tournament['division']
    end

    def test_has_valid_year
      assert_instance_of Integer, @tournament['year']
    end

    def test_has_valid_date
      assert_instance_of Date, @tournament['date']
    end
  end
end
