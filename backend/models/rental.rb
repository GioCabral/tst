require 'date'

class Rental
  attr_reader :id, :car_id, :start_date, :end_date, :distance, :options

  OPTION_PRICES = {
    "gps" => 500,
    "baby_seat" => 200,
    "additional_insurance" => 1000
  }

  def initialize(id, car_id, start_date, end_date, distance, options = [])
    raise 'start_date is nil' if start_date.nil?
    raise 'end_date is nil' if end_date.nil?

    @id = id
    @car_id = car_id
    @start_date = Date.parse(start_date)
    @end_date = Date.parse(end_date)
    @distance = distance
    @options = options
  end

  def rental_days
    (@end_date - @start_date).to_i + 1
  end

  def calculate_price(car)
    time_component = rental_days * car.price_per_day
    distance_component = @distance * car.price_per_km
    time_component + distance_component
  end

  def calculate_discounted_price(car)
    total_price = 0

    rental_days.times do |day|
      daily_price = car.price_per_day

      if day >= 10
        daily_price *= 0.5
      elsif day >= 4
        daily_price *= 0.7
      elsif day >= 1
        daily_price *= 0.9
      end

      total_price += daily_price
    end

    distance_component = @distance * car.price_per_km
    total_price + distance_component
  end

  def calculate_commission(price)
    total_commission = (price * 0.3).to_i

    insurance_fee = (total_commission / 2).to_i
    assistance_fee = rental_days * 100
    drivy_fee = total_commission - insurance_fee - assistance_fee

    {
      insurance_fee: insurance_fee,
      assistance_fee: assistance_fee,
      drivy_fee: drivy_fee
    }
  end

  def calculate_options_cost
    options_cost = @options.reduce(0) do |sum, option|
      sum + OPTION_PRICES[option] * rental_days
    end

    options_cost
  end

  def calculate_actions(car, with_discount: false)
    price = with_discount ? calculate_discounted_price(car) : calculate_price(car)
    commission = calculate_commission(price)
    owner_amount = price - commission.values.sum + calculate_options_cost
    driver_debit = price + calculate_options_cost

    [
      { who: 'driver', type: 'debit', amount: driver_debit },
      { who: 'owner', type: 'credit', amount: owner_amount },
      { who: 'insurance', type: 'credit', amount: commission[:insurance_fee] },
      { who: 'assistance', type: 'credit', amount: commission[:assistance_fee] },
      { who: 'drivy', type: 'credit', amount: commission[:drivy_fee] + (OPTION_PRICES["additional_insurance"] * rental_days if @options.include?("additional_insurance")).to_i }
    ]
  end
end
