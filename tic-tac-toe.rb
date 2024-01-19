class Game
  PLAYER_X = "X"
  PLAYER_O = "O"
  EMPTY_CELL = "-"
  BOARD_SIZE = 9
  LINES = [[0, 1, 2], [3, 4, 5], [6, 7, 8], [0, 3, 6], [1, 4, 7], [2, 5, 8], [0, 4, 8], [2, 4, 6]]

  def initialize
    @board = Array.new(BOARD_SIZE, EMPTY_CELL)
    @current_player = PLAYER_X
  end

  #Print the current state of the board
  def print_board
    @board.each_slice(3).with_index do |row, i|
      puts "#{i}  #{row.join(" | ")}"
      puts "  ---+---+---" unless i == 2
    end
  end

  #Makes a move for the current player at the given position
  def make_move(position)
    raise "Invalid move: position #{position} is either out of range or already occupied" unless valid_move?(position)
    @board[position] = @current_player
    switch_player unless game_over?
  end

  #Check if move is valid
  def valid_move?(position)
    return false if position < 0 || position >= BOARD_SIZE
    return false if @board[position] != EMPTY_CELL
    true
  end

  #Switches the current player
  def switch_player
    @current_player = @current_player == PLAYER_X ? PLAYER_O : PLAYER_X
  end

  def game_over?
    return true if win?
    return "Draw" if board_full?
    nil
  end

  def play
    result = nil
    until result
      begin
        puts "\n\n"
        print_board
        puts "Current Player: #{@current_player}"
        puts "Enter Current Move: "
        position = gets.chomp.to_i
        make_move(position)
        result = game_over?
      rescue RuntimeError => e
        puts e.message
        retry
      end
    end
    print_board
    puts "\nGame Over!"
    puts "Winner: Player #{@current_player}" unless result == "Draw"
    puts "It's a draw!" if result == "Draw"
    if replay?
      self.initialize
      system "clear"
      play
    end
  end
  
  def replay?
    puts "\nWanna Rematch(\"Yes\" for continue, \"No\" for stop?"
    answer = gets.chomp.downcase
    return true if answer == "yes"
    nil
  end

  private
  def win?
    LINES.any? do |line|
      @board.values_at(*line).uniq.length == 1 && @board[line[0]] != EMPTY_CELL
    end
  end

  def board_full?
    @board.none?(EMPTY_CELL)
  end
end

system "clear"
puts "Welcome player!"
Game.new.play
