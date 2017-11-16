require 'csv'

class Spread
  def self.calculate(args)
    if args[:benchmark]
      p "Benchmark calculation"
      p benchmark(args[:input])
    end
    if args[:curve]
      p "Curve calculation"
      p curve(args[:input])
    end
  end
  def self.benchmark(csv)
    CSV.foreach(csv) do |row|
      p row
    end
  end
  def self.curve(csv)
    CSV.foreach(csv) do |row|
      p row
    end
  end
end
