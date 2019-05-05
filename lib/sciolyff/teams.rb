# frozen_string_literal: true

require 'minitest/test'
require 'set'

module SciolyFF
  # Tests that also serve as the specification for the sciolyff file format
  #
  class Teams < Minitest::Test
    def setup
      skip unless SciolyFF.rep.instance_of? Hash
      @teams = SciolyFF.rep['Teams']
      skip unless @teams.instance_of? Array
    end

    def test_has_valid_teams
      @teams.each do |team|
        assert_instance_of Hash, team
      end
    end

    def test_each_team_does_not_have_extra_info
      @teams.select { |t| t.instance_of? Hash }.each do |team|
        fo = Set.new %w[school suffix subdivision exhibition number city state]
        assert Set.new(team.keys).subset? fo
      end
    end

    def test_each_team_has_valid_school
      @teams.select { |t| t.instance_of? Hash }.each do |team|
        assert_instance_of String, team['school']
      end
    end

    def test_each_team_has_valid_suffix
      @teams.select { |t| t.instance_of? Hash }.each do |team|
        assert_instance_of String, team['suffix'] if team.key? 'suffix'
      end
    end

    def test_each_team_has_valid_subdivision
      @teams.select { |t| t.instance_of? Hash }.each do |team|
        assert_instance_of String, team['subdivision'] \
          if team.key? 'subdivision'
      end
    end

    def test_each_team_has_valid_exhibition
      @teams.select { |t| t.instance_of? Hash }.each do |team|
        assert_includes [true, false], team['exhibition'] \
          if team.key? 'exhibition'
      end
    end

    def test_each_team_has_valid_number
      @teams.select { |t| t.instance_of? Hash }.each do |team|
        assert_instance_of Integer, team['number']
      end
    end

    def test_each_team_has_valid_city
      @teams.select { |t| t.instance_of? Hash }.each do |team|
        assert_instance_of String, team['city']
      end
    end

    def test_each_team_has_valid_state
      @teams.select { |t| t.instance_of? Hash }.each do |team|
        assert_instance_of String, team['state']
      end
    end

    def test_each_team_has_unique_number
      numbers = @teams.select { |t| t.instance_of? Hash }
                      .map { |t| t['number'] }
      assert_nil numbers.uniq!
    end
  end
end
