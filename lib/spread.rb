require 'csv'
require "bigdecimal"
require 'bigdecimal/util'
require 'byebug'
class Spread
  def self.calculate(args)
    data = self.parse_data(args[:input])
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
    government_bonds = data.select{|bond| bond["type"] == "government"}

    data.select{|bond| bond["type"] == "corporate"}.each do |bond|
      benchmark = self.best_benchmark_for(bond, government_bonds)

      spread = (bond["yield"].to_d - benchmark["yield"].to_d).to_digits #Is it possible for gov bond yield to exceed corp. yield?
      result << [bond["bond"], benchmark["bond"], spread + "%"]
    end
    result
  end

  def self.curve(data)
    result = [["bond", "spread_to_curve"]]
  end

  def self.best_benchmark_for(corporate_bond, government_bonds)
    closest = nil

    government_bonds.each do |bond|
      if closest.nil? || (bond["term"].to_d - corporate_bond["term"].to_d).abs < (closest["term"].to_d - corporate_bond["term"].to_d).abs
        closest = bond #TODO: In the case of two bonds with the same time, we probably want the one with the greater yield.
      end
    end
    closest
  end
end
