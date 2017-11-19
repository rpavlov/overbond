# Usage

    $ ./spread --benchmark --curve -i sample_input.csv

Depending on your desired output supply -c or -b for just curve or benchmark.

    $ ./spread -h

If confused.

# Prerequisites

ruby >= 2.4.2

# Testing

    $ rspec

# Assumptions

* A well-formed CSV input.
* Usable data, in terms of bond terms and presence of government bonds.

# TODO

* CSV format validation.
* Handling wonky data, i.e all government terms occurring before/after corp terms, no gov bonds in csv.
* Consideration for yields. Is term maturity more important than higher yield?
* More edge-case tests.