require 'csv'

CSV.foreach(filename, :headers => true) do |row|
  Moulding.create!(row.to_hash)
end
