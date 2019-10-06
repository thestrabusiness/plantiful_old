require 'rails_helper'

describe CheckIn do
  describe 'validations' do
    it { should validate_presence_of(:performed_by) }
    it { should validate_presence_of(:plant) }
  end
end
