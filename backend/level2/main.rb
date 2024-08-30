require 'json'
require_relative '../controllers/rental_service'

file = File.read('./data/input.json')
data = JSON.parse(file)

cars = data['cars']
rentals = data['rentals']

rental_service = RentalService.new(cars, rentals)
output = rental_service.generate_output(with_discount: true, include_commission: false, include_actions: false, include_price: true, include_options: false)

puts JSON.pretty_generate(output)
File.open('./data/output.json', 'w') do |f|
  f.write(JSON.pretty_generate(output))
end
