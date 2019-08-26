# SciolyFF (Science Olympiad File Format)

[![Gem Version](https://badge.fury.io/rb/sciolyff.svg)](https://badge.fury.io/rb/sciolyff)

We propose a standardized file format called SciolyFF to represent Science
Olympiad tournament results. This will allow for a more universal record of
tournament performance and also make it easier to do sabermetric-like stats and
other fun stuff. The format is a subset of YAML for easy implementation of
parsers across many programming languages.

A website that generates results tables based off SciolyFF files can be found
[here](https://unosmium.org/results/) and the source code for the website
[here](https://github.com/unosmium/unosmium.org).

## Specification

Reading through the demo file [here](examples/demo.yaml) is probably the fastest
way to get acquainted with the format. Officially, any file that passes the
validation (see Usage -- Validation) is valid, but the intentions of the format
outlined in the comments of the demo file should be respected.

## Installation

```
gem install sciolyff
```

This gem is currently in an alpha stage. To get the latest changes before
official releases, build from source:

```
git clone https://github.com/unosmium/sciolyff.git && cd sciolyff
gem build sciolyff.gemspec
gem install ./sciolyff-0.5.3.gem
```

## Usage

### Validation

A Ruby gem provided in this repository contains a command line utility that can
validate if a given file meets the SciolyFF. The validation uses Minitest, and
thus the files found in `lib/sciolyff` also serve as the specification for the
format.

From the command line, e.g.

```
sciolyff examples/nats_c_2017.yaml
```

Inside Ruby code, e.g.

```ruby
require 'sciolyff'

SciolyFF.validate_file('examples/nats_c_2017.yaml') #=> true
```

### Parsing

Although the SciolyFF makes the results file human-readable without the
ambiguity of spreadsheet results, it can be a bit awkward to parse overall
results -- for instance, when trying to regenerate a results spreadsheet from a
SciolyFF file.

To make this easier, a `SciolyFF::Interpreter` class has been provided to wrap
the output of Ruby's yaml parser. For example:

```ruby
require 'sciolyff'
require 'yaml'

rep = YAML.load(File.read('examples/nats_c_2017.yaml'), symbolize_names: true)
i = SciolyFF::Interpreter.new(rep)

a_and_p = i.events.find { |e| e.name == 'Anatomy and Physiology' }
a_and_p.trialed? #=> false

team_one = i.teams.find { |t| t.number == 1 }
team_one.placing_for(a_and_p).points #=> 7
team_one.points #=> 448

# sorted by rank
i.teams #=> [#<...{:school=>"Troy H.S.", :number=>3, :state=>"CA"}>, ... ]
```

A fuller example can be found here in the code for the Unosmium Results website,
found
[here](https://github.com/unosmium/unosmium.org/blob/master/source/results/template.html.erb).
There is also of course the
[documentation](https://www.rubydoc.info/gems/sciolyff/0.5.3), a bit sparse
currently.
