require_relative '../lib/tic-tac-toe'

describe TicTacToe do
  let(:player_1) { TicTacToe::Human }
  let(:player_2) { TicTacToe::Human }
  let(:game) { TicTacToe::Game.new(player_1, player_2) }


  describe "#initialize" do
    it 'initializes with an empty board' do
      expect(game.board).to all(eq(TicTacToe::EMPTY_CELL))
    end

    it 'assigns the first player to go' do
      expect(game.current_player).to be_an_instance_of(player_1)
    end
  end

  describe "#play" do
    # Public Script Method -> No test necessary, but all methods inside should
    # be tested.
  end

  describe "#replay?" do
    it 'asks for replay and returns true if yes' do
      allow_any_instance_of(Kernel).to receive(:gets).and_return("yes\n")
      expect(TicTacToe::Game.replay?).to be true
    end

    it 'asks for replay and returns nil if no' do
      allow_any_instance_of(Kernel).to receive(:gets).and_return("no\n")
      expect(TicTacToe::Game.replay?).to be_nil
    end
  end

  describe "#print_board" do
  end

  describe "#free_positions" do
    it 'returns all positions initially' do
      expect(game.free_positions).to match_array((0..8).to_a)
    end

    it 'returns fewer positions after a move' do
      game.make_move(game.current_player) # Assuming make_move takes the position as an argument
      expect(game.free_positions).not_to include(0)
    end

    it 'returns an empty array when the board is full' do
      # Make all positions occupied
      game.board.fill(game.current_player.marker)
      expect(game.free_positions).to be_empty
    end
  end

  describe "#make_move" do
    let(:game) { TicTacToe::Game.new(TicTacToe::Human, TicTacToe::Human) }
    let(:player) { game.current_player }
    let(:position) {  0 }

    before do
      allow(player).to receive(:select_position).and_return(position)
    end

    it 'switches the current player after making a move' do
      expect { game.make_move(player) }.to change { game.current_player }.from(player).to(game.opponent)
    end

    it 'does not switch the current player if the game is over' do
      allow(game).to receive(:game_over?).and_return(true)
      expect { game.make_move(player) }.not_to change { game.current_player }
    end
  end
  
  describe "#switch_player" do
    let(:game) { TicTacToe::Game.new(TicTacToe::Human, TicTacToe::Human) }
    let(:player1) { game.players[0] }
    let(:player2) { game.players[1] }

    it 'switches the current player' do
      expect(game.current_player).to eq(player1)
      game.switch_player
      expect(game.current_player).to eq(player2)
    end
  end

  describe "#opponent" do
    let(:game) { TicTacToe::Game.new(TicTacToe::Human, TicTacToe::Human) }
    let(:player1) { game.players[0] }
    let(:player2) { game.players[1] }

    it 'returns the player who is not the current player' do
      expect(game.opponent).to eq(player2)
      game.switch_player
      expect(game.opponent).to eq(player1)
    end
  end

  describe "turn_num" do
    let(:game) { TicTacToe::Game.new(TicTacToe::Human, TicTacToe::Human) }
    let(:player) { game.current_player }
    let(:position) {  0 }

    before do
      allow(player).to receive(:select_position).and_return(position)
    end

    it 'starts at 1 for the first turn' do
      expect(game.turn_num).to eq(1)
    end

    it 'increments after a move' do
      game.make_move(player)
      expect(game.turn_num).to eq(2)
    end

    it 'reflects the number of filled positions' do
      game.board.fill(player.marker)
      expect(game.turn_num).to eq(10)
    end
  end

  describe "game_over?" do
    let(:game) { TicTacToe::Game.new(TicTacToe::Human, TicTacToe::Human) }

    context 'when the game has a winner' do
      before do
        # Set up a winning condition on the board
        game.board[0] = game.players[0].marker
        game.board[1] = game.players[0].marker
        game.board[2] = game.players[0].marker
      end

      it 'returns true' do
        expect(game.game_over?).to be true
      end
    end

    context 'when the game is tied' do
      before do
        # Fill the board completely to simulate a tie
        game.board.fill(game.players[0].marker)
        game.board[0] = game.players[1].marker
      end

      it 'returns true' do
        expect(game.game_over?).to eq("Draw")
      end
    end

    context 'when the game is not over' do
      it 'returns false' do
        expect(game.game_over?).to be nil
      end
    end
  end

  describe "win?" do
    let(:game) { TicTacToe::Game.new(TicTacToe::Human, TicTacToe::Human) }
    let(:player1) { game.players[0] }
    let(:player2) { game.players[1] }

    context 'when player  1 has a row win' do
      before do
        # Set up a row win for player  1
        game.board[0] = player1.marker
        game.board[1] = player1.marker
        game.board[2] = player1.marker
      end

      it 'returns true for player  1' do
        expect(game.win?).to be true
      end
    end

    context 'when player  2 has a column win' do
      before do
        # Set up a column win for player  2
        game.board[0] = player2.marker
        game.board[3] = player2.marker
        game.board[6] = player2.marker
      end

      it 'returns true for player  2' do
        expect(game.win?).to be true
      end
    end

    context 'when there is no win' do
      it 'returns false' do
        expect(game.win?).to be_falsey
      end
    end

  end

  describe "board_full?" do
    let(:game) { TicTacToe::Game.new(TicTacToe::Human, TicTacToe::Human) }

    context 'when the board is not full' do
      it 'returns false' do
        # Assuming the board starts empty
        expect(game.board_full?).to be false
      end
    end

    context 'when the board is full' do
      before do
        # Fill the board completely to simulate a full board
        game.board.fill(game.players[0].marker)
      end

      it 'returns true' do
        expect(game.board_full?).to be true
      end
    end
  end
end

RSpec.describe TicTacToe::Human do
  let(:game) { TicTacToe::Game.new(TicTacToe::Human, TicTacToe::Human) }
  let(:human) { TicTacToe::Human.new(game, "O") }

  describe '#select_position' do
    it 'prompts for input and returns a valid position' do
      allow($stdin).to receive(:gets).and_return("0\n")
      expect(human.select_position).to eq(0)
    end

    it 'loops until a valid position is entered' do
      allow($stdin).to receive(:gets).and_return("-1\n", "9\n", "0\n")
      expect(human.select_position).to eq(0)
    end
  end
end