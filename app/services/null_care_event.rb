class NullCareEvent
  attr_accessor :plant

  def initialize(plant)
    @plant = plant
  end

  def happened_at
    Time.at(0)
  end

  def happened_at_date
    I18n.l(happened_at, format: :month_day_year)
  end
end
