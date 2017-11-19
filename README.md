# Usage

    $ ./spread --benchmark --curve -i sample_input.csv

Depending on your desired output, supply just -c or -b for either curve or benchmark calculation respectively.

    $ ./spread -h

If confused.

# Prerequisites

ruby >= 2.4.2

# Technical choices

* optparse for better handling of command line arguments
* BigDecimal for working with decimals/money.
* CSV for parsing csv inputs.

# Testing

    $ rspec

# Assumptions

* A well-formed CSV input.
* Usable data, for bond terms and actual presence of government bond rows.

# TODO

* CSV format validation.
* Handling wonky data, i.e all government terms occurring before/after corp terms, no gov bonds in csv.
* Consideration for yields. Is term maturity more important than higher yield?
* More edge-case tests.
