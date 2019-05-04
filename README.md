# Science Olympiad File Formats

We propose standardized file formats for Science Olympiad scoring to allow for a
more universal record of tournament results and thus make it easier to do
sabermetric-like stats and stuff. The formats are a subset of YAML for easy
implementation of parsers across many programming languages.

## File Specification / Validation

A Ruby gem provided in this repository contains a command line utility that can
validate if a given file meets the SciolyFF. The validation uses Minitest, and
thus the files found in `lib/sciolyff` also serve as the specification for the
format.

To run the command line utility without installing the gem:

```
ruby -Ilib bin/sciolyff examples/demo.rb
```

Installing the gem simplifies this to the following and will also install any
missing dependencies:

```
sciolyff examples/demo.rb
```

## Installation

After this gem is pushed to https://rubygems.org/ the installation will be:

```
gem install sciolyff
```

Until then, the gem can be built and installed locally:

```
gem build sciolyff.gemspec
gem install ./sciolyff-0.1.1.gem
```
