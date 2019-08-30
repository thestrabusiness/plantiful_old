class PlantCheckIn
  attr_reader :plant, :event_params

  def initialize(plant, event_params)
    @plant = plant
    @event_params = event_params
  end

  def self.perform(plant, event_params)
    new(plant, event_params).perform
  end

  private

  def perform; end
end
