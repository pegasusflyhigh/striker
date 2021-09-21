require 'rails_helper'

RSpec.describe ScoreUpdater do
  let(:game) { create(:game) }
  let(:player) { create(:player, game_id: game.id) }
  let(:first_round) { player.rounds.first }
  let(:second_round) { player.rounds.second }

  context 'validations' do
    it 'should validate presence of round' do
      service = described_class.new({ pins: 5, roll: 1 })

      expect(service.valid?).to be false
      expect(service.errors.messages[:round]).to eq ["can't be blank"]
    end

    it 'should validate presence of pins' do
      service = described_class.new({ round: first_round, roll: 1 })

      expect(service.valid?).to be false
      expect(service.errors.messages[:pins]).to include("can't be blank")
    end

    it 'should validate presence of roll' do
      service = described_class.new({ round: first_round, pins: 4 })

      expect(service.valid?).to be false
      expect(service.errors.messages[:roll]).to include I18n.t('roll.errors.invalid')
    end

    it 'should validate inclusion of roll in 1,2 or 3' do
      service = described_class.new({ round: first_round, pins: 4, roll: 5 })

      expect(service.valid?).to be false
      expect(service.errors.messages[:roll]).to include I18n.t('roll.errors.invalid')
    end

    it 'should validate pins to be an integer' do
      service = described_class.new({ round: first_round, pins: "hey", roll: 1 })

      expect(service.valid?).to be false
      expect(service.errors.messages[:pins]).to include("is not a number")
    end

    it 'should validate if game has finished' do
      allow_any_instance_of(Game).to receive(:status).and_return('finished')
      service = described_class.new({ round: first_round, pins: 4, roll: 1 })

      expect(service.valid?).to be false
      expect(service.errors.messages[:base]).to include I18n.t('game.errors.finished_game')
    end

    it 'should validate if round has completed' do
      allow_any_instance_of(Round).to receive(:strike?).and_return(true)
      service = described_class.new({ round: first_round, pins: 4, roll: 1 })

      expect(service.valid?).to be false
      expect(service.errors.messages[:base]).to include I18n.t('round.errors.already_finished')
    end

    context 'should validate given pins' do
      it 'when it is not first round and previous round scores are empty' do
        service = described_class.new({ round: second_round, pins: 4, roll: 1 })

        expect(service.valid?).to be false
        expect(service.errors.messages[:base]).to include I18n.t('round.errors.invalid_score')
      end

      it 'when it is not first round and previous roll score is empty' do
        allow(first_round).to receive(:scores).and_return([2, 4])
        service = described_class.new({ round: second_round, pins: 4, roll: 2 })

        expect(service.valid?).to be false
        expect(service.errors.messages[:base]).to include I18n.t('round.errors.invalid_score')
      end
    end
  end

  describe '.call' do
    it 'returns true if service runs successfully' do
      service = described_class.new({ round: first_round, pins: 4, roll: 1 })
      expect(service.call).to be_truthy
    end

    it 'returns error if service encounters anyy error' do
      service = described_class.new({ round: first_round, pins: 4, roll: 6 })
      expect(service.call).to be_falsey
      expect(service.errors.messages).to be_present
    end
  end

  describe 'when pins for first roll is given' do
    it "updates score with pins for first roll" do
      service = described_class.new({ round: first_round, pins: 3, roll: 1 })
      service.call

      expect(first_round.scores).to eq([3])
    end

    context 'if previous round was a strike' do
      before do
        first_round.scores = [Round::PINS, nil, nil]
        first_round.save
      end

      it "updates the previous round with score = [#{Round::PINS}, own_score_for_roll_1, nil]" do
        service = described_class.new({ round: second_round, pins: 3, roll: 1 })
        service.call

        expect(first_round.reload.scores).to eq([Round::PINS, 3, nil])
        expect(second_round.scores).to eq([3])
      end

      context 'previous to previous round was also a strike' do
        before do
          first_round.scores = [Round::PINS, Round::PINS, nil]
          first_round.save
          second_round.scores = [Round::PINS, nil, nil]
          second_round.save
        end

        it "updates the previous to previous round with score = [#{Round::PINS}, previous_round_roll_1_score, own_score_for_roll_1]" do
          third_round = player.rounds.third
          service = described_class.new({ round: third_round, pins: 3, roll: 1 })
          service.call

          expect(third_round.reload.scores).to eq([3])
          expect(second_round.reload.scores).to eq([Round::PINS, 3, nil])
          expect(first_round.reload.scores).to eq([Round::PINS, Round::PINS, 3])
        end
      end
    end

    context 'if previous round was a spare' do
      before do
        first_round.scores = [4, Round::PINS - 4, nil]
        first_round.save
      end

      it "updates the previous round with score = [4, #{Round::PINS - 4}, own_score_for_roll_1]" do
        service = described_class.new({ round: second_round, pins: 3, roll: 1 })
        service.call

        expect(first_round.reload.scores).to eq([4, Round::PINS - 4, 3])
        expect(second_round.scores).to eq([3])
      end
    end
  end

  describe 'when current round is a strike' do
    it "updates score with [#{Round::PINS}, nil, nil]" do
      service = described_class.new({ round: first_round, pins: Round::PINS, roll: 1 })
      service.call

      expect(first_round.scores).to eq([Round::PINS, nil, nil])
    end
  end

  describe 'when current round is a spare' do
    before do
      first_round.scores = [4]
      first_round.save
    end

    it "updates score with [first_roll_score, second_roll_score, nil]" do
      service = described_class.new({ round: first_round, pins: Round::PINS - 4, roll: 2 })
      service.call

      expect(first_round.scores).to eq([4, Round::PINS - 4, nil])
    end
  end

  describe 'when current round is neither spare nor strike' do
    before do
      first_round.scores = [4]
      first_round.save
    end

    it "updates score with [first_roll_score, second_roll_score]" do
      service = described_class.new({ round: first_round, pins: Round::PINS - 6, roll: 2 })
      service.call

      expect(first_round.scores).to eq([4, Round::PINS - 6])
    end
  end
end
