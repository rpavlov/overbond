require 'spread'
require 'spec_helper'

describe Spread do
  context "Command line tool" do
    it "aborts without input" do
      expect(%x(./spread -c -b)).to eq("Missing input file\n")
    end
    it "yields correctly formatted output" do
      expect(%x(./spread -b -i ./spec/fixtures/sample_input.csv)).to eq("bond,benchmark,spread_to_benchmark\nC1,G1,1.6%\n")
      expect(%x(./spread -c -i ./spec/fixtures/sample_input2.csv)).to eq("bond,spread_to_curve\nC1,1.22%\nC2,2.98%\n")
    end
  end

  context "Business logic" do
    it "converts the csv to array of hashes" do
      expect(Spread.parse_data('./spec/fixtures/sample_input.csv')).to match_array(
        [{"bond"=>"C1", "type"=>"corporate", "term"=>"10.3", "yield"=>"5.30"},
        {"bond"=>"G1", "type"=>"government", "term"=>"9.4", "yield"=>"3.70"},
        {"bond"=>"G2", "type"=>"government", "term"=>"12", "yield"=>"4.80"}])
    end

    it "yields the correct benchmark" do
      data = Spread.parse_data('./spec/fixtures/sample_input.csv')

      expect(Spread.benchmark(data)).to eq([["bond", "benchmark", "spread_to_benchmark"], ["C1", "G1", "1.6%"]])
    end

    it "yields the correct curve" do
      data = Spread.parse_data('./spec/fixtures/sample_input2.csv')

      expect(Spread.curve(data)).to eq([["bond", "spread_to_curve"], ["C1", "1.22%"], ["C2", "2.98%"]])
    end

    it "finds the best government benchmark for a corporate bond" do
      corp = {"bond"=>"C1", "type"=>"corporate", "term"=>"1", "yield"=>"3.70"}
      gov1 = {"bond"=>"G1", "type"=>"government", "term"=>"1.5", "yield"=>"3.70"}
      gov2 = {"bond"=>"G1", "type"=>"government", "term"=>"2", "yield"=>"3.70"}

      expect(Spread.best_benchmark_for(corp,[gov1,gov2])).to eq(gov1)
    end

    it "finds the two best government benchmarks for linear interpolation" do
      corp = {"bond"=>"C1", "type"=>"corporate", "term"=>"10.3", "yield"=>"5.30"}
      gov_bonds = [{"bond"=>"G1", "type"=>"government", "term"=>"9.4", "yield"=>"3.70"},
        {"bond"=>"G2", "type"=>"government", "term"=>"12", "yield"=>"4.80"},
        {"bond"=>"G3", "type"=>"government", "term"=>"16.3", "yield"=>"5.50"}
      ]

      expect(Spread.best_benchmarks_for_curve(corp,gov_bonds)).to match_array(
        [{"bond"=>"G1", "type"=>"government", "term"=>"9.4", "yield"=>"3.70"},
          {"bond"=>"G2", "type"=>"government", "term"=>"12", "yield"=>"4.80"}])
    end
    it "computes linear interpolation correctly" do
      corp = {"bond"=>"C1", "type"=>"corporate", "term"=>"10.3", "yield"=>"5.30"}
      gov1 = {"bond"=>"G1", "type"=>"government", "term"=>"9.4", "yield"=>"3.70"}
      gov2 =  {"bond"=>"G2", "type"=>"government", "term"=>"12", "yield"=>"4.80"}

      expect(Spread.linear_interpolation(corp,[gov1, gov2]).to_d).to eq(4.08)
    end
  end
end
