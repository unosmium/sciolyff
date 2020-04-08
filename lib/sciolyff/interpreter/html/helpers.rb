# frozen_string_literal: true

module SciolyFF
  # Holds helper methods used in template.html.erb
  class Interpreter::HTML::Helpers
    def template
      File.read(File.join(__dir__, 'template.html.erb'))
    end

    def get_binding(interpreter, hide_raw)
      i = interpreter
      binding
    end

    private

    STATES_BY_POSTAL_CODE = {
      AK: 'Alaska',
      AZ: 'Arizona',
      AR: 'Arkansas',
      CA: 'California',
      nCA: 'Northern California',
      sCA: 'Southern California',
      CO: 'Colorado',
      CT: 'Connecticut',
      DE: 'Delaware',
      DC: 'District of Columbia',
      FL: 'Florida',
      GA: 'Georgia',
      HI: 'Hawaii',
      ID: 'Idaho',
      IL: 'Illinois',
      IN: 'Indiana',
      IA: 'Iowa',
      KS: 'Kansas',
      KY: 'Kentucky',
      LA: 'Louisiana',
      ME: 'Maine',
      MD: 'Maryland',
      MA: 'Massachusetts',
      MI: 'Michigan',
      MN: 'Minnesota',
      MS: 'Mississippi',
      MO: 'Missouri',
      MT: 'Montana',
      NE: 'Nebraska',
      NV: 'Nevada',
      NH: 'New Hampshire',
      NJ: 'New Jersey',
      NM: 'New Mexico',
      NY: 'New York',
      NC: 'North Carolina',
      ND: 'North Dakota',
      OH: 'Ohio',
      OK: 'Oklahoma',
      OR: 'Oregon',
      PA: 'Pennsylvania',
      RI: 'Rhode Island',
      SC: 'South Carolina',
      SD: 'South Dakota',
      TN: 'Tennessee',
      TX: 'Texas',
      UT: 'Utah',
      VT: 'Vermont',
      VA: 'Virginia',
      WA: 'Washington',
      WV: 'West Virginia',
      WI: 'Wisconsin',
      WY: 'Wyoming'
    }.freeze

    def tournament_title(t_info)
      return t_info.name if t_info.name

      case t_info.level
      when 'Nationals'
        'Science Olympiad National Tournament'
      when 'States'
        "#{expand_state_name(t_info.state)} Science Olympiad State Tournament"
      when 'Regionals'
        "#{t_info.location} Regional Tournament"
      when 'Invitational'
        "#{t_info.location} Invitational"
      end
    end

    def tournament_title_short(t_info)
      case t_info.level
      when 'Nationals'
        'National Tournament'
      when 'States'
        "#{t_info.state} State Tournament"
      when 'Regionals', 'Invitational'
        t_info.short_name
      end
    end

    def acronymize(phrase)
      phrase.split(' ')
            .select { |w| /^[[:upper:]]/.match(w) }
            .map { |w| w[0] }
            .join
    end

    def expand_state_name(postal_code)
      STATES_BY_POSTAL_CODE[postal_code.to_sym]
    end

    def format_school(team)
      if team.school_abbreviation
        abbr_school(team.school_abbreviation)
      else
        abbr_school(team.school)
      end
    end

    def abbr_school(school)
      school.sub('Elementary School', 'Elementary')
            .sub('Elementary/Middle School', 'E.M.S.')
            .sub('Middle School', 'M.S.')
            .sub('Junior High School', 'J.H.S.')
            .sub(%r{Middle[ /-]High School}, 'M.H.S')
            .sub('Junior/Senior High School', 'Jr./Sr. H.S.')
            .sub('High School', 'H.S.')
            .sub('Secondary School', 'Secondary')
    end

    def full_school_name(team)
      location = if team.city then "(#{team.city}, #{team.state})"
                 else              "(#{team.state})"
                 end
      [team.school, location].join(' ')
    end

    def full_team_name(team)
      location = if team.city then "(#{team.city}, #{team.state})"
                 else              "(#{team.state})"
                 end
      [team.school, team.suffix, location].join(' ')
    end

    def team_attended?(team)
      team
        .placings
        .map(&:participated?)
        .any?
    end

    def summary_titles
      %w[
        Champion
        Runner-up
        Third-place
        Fourth-place
        Fifth-place
        Sixth-place
      ]
    end

    def sup_tag(placing)
      exempt = placing.exempt? || placing.dropped_as_part_of_worst_placings?
      tie = placing.tie? && !placing.points_limited_by_maximum_place?
      return '' unless tie || exempt

      "<sup>#{'◊' if exempt}#{'*' if tie}</sup>"
    end

    def placing_notes(placing)
      place = placing.place
      points = placing.isolated_points
      [
        ('trial event' if placing.event.trial?),
        ('trialed event' if placing.event.trialed?),
        ('disqualified' if placing.disqualified?),
        ('did not participate' if placing.did_not_participate?),
        ('participation points only' if placing.participation_only?),
        ('tie' if placing.tie?),
        ('exempt' if placing.exempt?),
        ('points limited' if placing.points_limited_by_maximum_place?),
        ('unknown place' if placing.unknown?),
        ('placed behind exhibition team'\
         if placing.points_affected_by_exhibition? && place - points == 1),
        ('placed behind exhibition teams'\
         if placing.points_affected_by_exhibition? && place - points > 1),
        ('dropped'\
         if placing.dropped_as_part_of_worst_placings?)
      ].compact.join(', ').capitalize
    end
  end
end
