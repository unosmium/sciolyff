# frozen_string_literal: true

require 'minitest/test'
require 'set'

module SciolyFF
  # Tests that also serve as the specification for the sciolyff file format
  #
  class Tournament < Minitest::Test
    def setup
      skip unless SciolyFF.rep.instance_of? Hash
      @tournament = SciolyFF.rep['Tournament']
      skip unless @tournament.instance_of? Hash
    end

    def test_has_info
      refute_nil @tournament['location']
      refute_nil @tournament['level']
      refute_nil @tournament['division']
      refute_nil @tournament['year']
      refute_nil @tournament['date']
    end

    def test_does_not_have_extra_info
      info = Set.new %w[name location level division year date]
      assert Set.new(@tournament.keys).subset? info
    end

    def test_has_valid_name
      skip unless @tournament['name']
      assert_instance_of String, @tournament['name']
    end

    def test_has_valid_location
      skip unless @tournament['location']
      assert_instance_of String, @tournament['location']
    end

    def test_has_valid_level
      skip unless (level = @tournament['level'])
      assert_includes %w[Invitational Regionals States Nationals], level
    end

    def test_has_valid_division
      skip unless @tournament['division']
      assert_includes %w[A B C], @tournament['division']
    end

    def test_has_valid_year
      skip unless @tournament['year']
      assert_instance_of Integer, @tournament['year']
    end

    def test_has_valid_date
      skip unless @tournament['date']
      assert_instance_of Date, @tournament['date']
    end
  end
end
