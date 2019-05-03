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
      @teams.select { |e| e.instance_of? Hash }.each do |team|
        info = Set.new %w[school suffix number city state]
        assert Set.new(team.keys).subset? info
      end
    end

    def test_each_team_has_valid_school
      @teams.select { |e| e.instance_of? Hash }.each do |team|
        assert_instance_of String, team['school']
      end
    end

    def test_each_team_has_valid_suffix
      @teams.select { |e| e.instance_of? Hash }.each do |team|
        assert_instance_of String, team['suffix']
      end
    end

    def test_each_team_has_valid_number
      @teams.select { |e| e.instance_of? Hash }.each do |team|
        assert_instance_of Integer, team['number']
      end
    end

    def test_each_team_has_valid_city
      @teams.select { |e| e.instance_of? Hash }.each do |team|
        assert_instance_of String, team['city']
      end
    end

    def test_each_team_has_valid_state
      @teams.select { |e| e.instance_of? Hash }.each do |team|
        assert_instance_of String, team['state']
      end
    end
  end
end
