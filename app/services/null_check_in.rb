class NullCheckIn
  attr_accessor :plant

  def initialize(plant)
    @plant = plant
  end

  def created_at
    Time.at(0)
  end

  def created_at_date
    I18n.l(created_at, format: :month_day_year)
  end
end
