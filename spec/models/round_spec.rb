require 'rails_helper'

RSpec.describe Round, type: :model do
  context 'associations' do
    it { should belong_to(:player).class_name('Player') }
    it { should belong_to(:game).class_name('Game') }
    it { should have_one(:previous) }
  end
end
