require 'csv'
require 'bigdecimal'
require 'bigdecimal/util'
require 'byebug'

class Spread
  def self.calculate(args)
    data = parse_data(args[:input])

    if args[:benchmark]
      puts benchmark(data).map{|row|row.join(",")}
    end
    if args[:curve]
      puts curve(data).map{|row|row.join(",")}
    end
  end

  #Convert to array of hashes and sanitize values
  def self.parse_data(csv)
    csv_array = CSV.read(csv)
    keys = csv_array.shift
    keys.map!(&:strip)
    data = csv_array.map {|row| Hash[ keys.zip(row) ] }
    data.map{|bond| bond.transform_values!{ |v| v.gsub(" years","").gsub("%", "").strip }}
  end

  def self.benchmark(data)
    result = [["bond", "benchmark", "spread_to_benchmark"]]

    data.select{|bond| bond["type"] == "corporate"}.each do |bond|
      benchmark = best_benchmark_for(bond, data.select{|bond| bond["type"] == "government"})

      spread = (bond["yield"].to_d - benchmark["yield"].to_d).abs.to_digits #Do we consider negative yield?
      result << [bond["bond"], benchmark["bond"], spread + "%"]
    end
    result
  end

  def self.curve(data)
    result = [["bond", "spread_to_curve"]]
    government_bonds = data.select{|bond| bond["type"] == "government"}

    data.select{|bond| bond["type"] == "corporate"}.each do |bond|

      spread = bond["yield"].to_d - linear_interpolation(bond, government_bonds).round(2)
      result << [bond["bond"], spread.to_digits + "%"]
    end
    result
  end

  def self.best_benchmark_for(corporate_bond, government_bonds)
    best_bonds = best_benchmarks_for_curve(corporate_bond, government_bonds).reject(&:nil?)

    #All bond terms are either before or after, not on either side (and one was therefore nil and excluded).
    if best_bonds.size == 1
      best_bonds[0]
    else
      before = (best_bonds[0]["term"].to_d - corporate_bond["term"].to_d).abs
      after =  (best_bonds[1]["term"].to_d - corporate_bond["term"].to_d).abs
      before < after ? best_bonds[0] : best_bonds[1]
    end
  end

  #Here we want to find two closest bonds, with terms closest before and after that of the corporate bond.
  def self.best_benchmarks_for_curve(corporate_bond, government_bonds)
    combined_bonds = (government_bonds << corporate_bond).sort_by{|bond| bond["term"].to_d}

    [combined_bonds[combined_bonds.index(corporate_bond) - 1], combined_bonds[combined_bonds.index(corporate_bond) + 1]]
  end

  def self.linear_interpolation(corporate_bond, government_bonds)
    bonds = best_benchmarks_for_curve(corporate_bond, government_bonds)

      ( bonds[0]["yield"].to_d * (bonds[1]["term"].to_d - corporate_bond["term"].to_d) +
      bonds[1]["yield"].to_d * ( corporate_bond["term"].to_d - bonds[0]["term"].to_d ) ) /
      (bonds[1]["term"].to_d - bonds[0]["term"].to_d)
  end
end
