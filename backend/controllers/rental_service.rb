require_relative '../models/car'
require_relative '../models/rental'

class RentalService
  def initialize(cars, rentals, options = [])
    @cars = cars.map { |car_data| Car.new(car_data['id'], car_data['price_per_day'], car_data['price_per_km']) }
    @rentals = rentals.map do |rental_data|
      rental_options = options.select { |option| option['rental_id'] == rental_data['id'] }.map { |option| option['type'] }
      Rental.new(rental_data['id'], rental_data['car_id'], rental_data['start_date'], rental_data['end_date'], rental_data['distance'], rental_options)
    end
  end

  def find_car_by_id(car_id)
    @cars.find { |car| car.id == car_id }
  end

  def calculate_rental_prices(with_discount: false, include_commission: false, include_actions: false, include_price: false, include_options: false)
    @rentals.map do |rental|
      car = find_car_by_id(rental.car_id)
      price = with_discount ? rental.calculate_discounted_price(car) : rental.calculate_price(car)

      rental_data = { id: rental.id}

      if include_price
        rental_data[:price] = price
      end

      if include_options
        rental_data[:options] = rental.options
      end

      if include_commission
        commission = rental.calculate_commission(price)
        rental_data[:commission] = commission
      end

      if include_actions
        actions = rental.calculate_actions(car, with_discount: with_discount)
        rental_data[:actions] = actions
      end

      rental_data
    end
  end

  def generate_output(with_discount: false, include_commission: false, include_actions: false, include_price: false, include_options: false)
    { rentals: calculate_rental_prices(with_discount: with_discount, include_commission: include_commission, include_actions: include_actions, include_price: include_price, include_options: include_options ) }
  end
end
