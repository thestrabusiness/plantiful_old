class NeedsCheckIn
  attr_reader :scope

  def initialize(scope)
    @scope = scope
  end

  def self.users(scope = User.all)
    new(scope).users
  end

  def self.plants(scope = Plant.all)
    new(scope).plants
  end

  def users
    needs_care_reminder(scope.joins(:plants, :check_ins))
  end

  def plants
    needs_care_reminder(scope.joins(:check_ins))
  end

  private

  def needs_care_reminder(scope)
    scope.where(
      'check_ins.created_at = (SELECT MAX(check_ins.created_at)
      FROM check_ins WHERE check_ins.plant_id = plants.id)'
    )
         .where(
           "check_ins.created_at + #{care_frequency_interval_sql} <= now()"
         )
         .where('plants.deleted_at IS NULL')
         .uniq
  end

  def care_frequency_interval_sql
    "(plants.check_frequency_scalar || ' ' || plants.check_frequency_unit::TEXT)::INTERVAL"
  end
end
