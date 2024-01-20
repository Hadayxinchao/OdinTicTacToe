module TicTacToe
  EMPTY_CELL = "-"
  BOARD_SIZE = 9
  LINES = [[0, 1, 2], [3, 4, 5], [6, 7, 8], [0, 3, 6], [1, 4, 7], [2, 5, 8], [0, 4, 8], [2, 4, 6]]

  class Game
    def initialize(player_1, player_2)
      @board = Array.new(BOARD_SIZE, EMPTY_CELL)
      @players = [player_1.new(self, "X"), player_2.new(self, "O")]
      @current_player = @players[0]
      puts "#{@current_player} goes first"
    end
    attr_reader :board
    
    def play
      result = nil
      until result
        make_move(@current_player)
        result = game_over?
      end
      print_board
      puts "\nGame Over!"
      puts "Winner: Player #{@current_player}" unless result == "Draw"
      puts "It's a draw!" if result == "Draw"
    end
    
    def self.replay?
      puts "\nWanna Play Again? (\"Yes\" for continue, \"No\" for stop)"
      answer = gets.chomp.downcase
      return true if answer == "yes"
      nil
    end

    #Print the current state of the board
    def print_board
      @board.each_slice(3).with_index do |row, i|
        puts "#{i}  #{row.join(" | ")}"
        puts "  ---+---+---" unless i == 2
      end
    end

    #Check if there is free position in board
    def free_positions
      return (0..9).select {|position| @board[position] == EMPTY_CELL}
    end

    def make_move(player)
      position = player.select_position
      puts "#{player} selects #{player.marker} position #{position}"
      @board[position] = player.marker
      switch_player unless game_over?
    end
    #Switches the current player
    def switch_player
      @current_player = @current_player == @players[0] ? @players[1] : @players[0]
    end

    def opponent
      @current_player == @players[0] ? @players[1] : @players[0]
    end

    def turn_num
      10 - free_positions.size
    end

    def game_over?
      return "Draw" if board_full?
      return true if win?
      nil
    end

    private
    def win?
      LINES.any? do |line|
        @board.values_at(*line).uniq.length == 1 && @board[line[0]] != EMPTY_CELL
      end
    end

    def board_full?
      free_positions.empty?
    end
  end

  class Player
    def initialize(game, marker)
      @game = game
      @marker = marker
    end
    attr_reader :marker
  end

  class Human < Player
    def select_position
      @game.print_board
      loop do
        print "Select your #{marker} position: "
        position = gets.chomp.to_i
        return position if @game.free_positions.include?(position)
        puts "Position #{position} is not available. Try again."
      end
    end

    def to_s
      "Human#{@marker == "X" ? 1 : 2}"
    end
  end

  class Computer < Player
    def group_positions_by_markers(line)
      markers = line.group_by{ |position| @game.board[position] }
      markers.default = []
      markers
    end

    def select_position
      opponent_marker = @game.opponent.marker

      winning_or_blocking_position = look_for_winning_or_blocking_position(opponent_marker)
      return winning_or_blocking_position if winning_or_blocking_position

      corner_trap_defense_position(opponent_marker) if corner_trap_defense_needed?

      return random_prioritized_position
    end

    def look_for_winning_or_blocking_position(opponent_marker) 
      for line in LINES
        markers = group_positions_by_markers(line)
        next if markers[nil].length != 1
        if markers[self.marker].length == 2
          return markers[nil].first
        elsif markers[opponent_marker].length == 2
          blocking_position = markers[nil].first
        end
      end
      if blocking_position
        return blocking_position
      end
    end

    def corner_trap_defense_needed?
      corner_positions = [0, 2, 6, 8]
      opponent_chose_a_corner = corner_positions.any?{|pos| @game.board[pos] != EMPTY_CELL}
      return @game.turn_num == 2 && opponent_chose_a_corner
    end

    def corner_trap_defense_position(opponent_marker)
      opponent_position = @game.board.find_index {|marker| marker == opponent_marker}
      safe_responses = {0=>[1,3], 2=>[1,5], 6=>[3,5], 8=>[5,7]}
      return safe_responses[opponent_position].sample
    end
    
    def random_prioritized_position
      ([4] + [0,2,6,8].shuffle + [1,3,5,7].shuffle).find do |pos|
        @game.free_positions.include?(pos)
      end
    end

    def to_s
      "Computer"
    end
  end
end

include TicTacToe

system "clear"
puts "Welcome player!"

ready = false
until ready
  puts "Select your mode:", "1. PvP (Friend Battle)", "2. PvE (Vs Computer)", "Other. Exit"
  selection = gets.chomp.to_i
  if selection == 1
    Game.new(Human, Human).play
    if Game.replay?
      self.initialize
      system "clear"
    else
      ready = true
    end
  elsif selection == 2
    players_with_human = [Human, Computer].shuffle
    Game.new(*players_with_human).play
    if Game.replay?
      self.initialize
      system "clear"
    else
      ready = true
    end
  else
    ready = true
  end
end

puts "\n-----------------------------------"
puts "Goodbye, have a good day with Odin!"
puts "\n-----------------------------------"