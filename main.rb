#!/usr/bin/env ruby
require "httparty"
require "bundler"
require "logger"
require "stringio"
require_relative "match"

PINS = {
  left_button_pin: 3,
  right_button_pin: 2,
  clock_pin: 17,
}.freeze

P1_SHIFT_REGISTER = '/dev/spidev0.0'.freeze
P2_SHIFT_REGISTER = '/dev/spidev0.1'.freeze

INACTIVITY_TIMEOUT = 10 * 60 # seconds
BEFORE_PLAYER_SELECTION_DELAY = 0.5 # seconds (should be long enough for all effects - especiall blink and scroll - to end)
PLAYER_SELECTION_DELAY = 0.75 # seconds

OFFICE_API_URL = "https://api.buero.die-antwort.eu/resources/data_items".freeze
OFFICE_API_TOKEN = ENV['API_TOKEN'].freeze

class Main
  attr_reader :score_board, :match, :players

  def initialize(input, score_board)
    @input = input
    @score_board = score_board
    @last_activity_at = Time.now
    Thread.abort_on_exception = true
    Thread.new do
      loop do
        if Time.now - @last_activity_at > INACTIVITY_TIMEOUT
          $logger.info "Inactivity timeout reachend, exiting"
          exit
        end
        sleep(1)
      end
    end
  end

  def run
    loop do
      score_board.display(nil, nil)
      $logger.info "Waiting for button press to start up"
      @input.get
      $logger.info "Starting match"
      @last_activity_at = Time.now

      @score_board.display('PLAYER ', 'PLAYER ', effect: :scroll)
      @input.get
      begin
        @score_board.display(nil, nil)
        sleep(BEFORE_PLAYER_SELECTION_DELAY) # Make sure any previous effect (scrolling, blinking) has ended (so that first player number is displayed immediately)
        @players = ask_for_players
        @score_board.display(*players, effect: :blink)
      end while @input.get.undo?

      max_game_count = ask_for_max_game_count
      side_having_first_service = ask_for_side_having_first_service

      loop do
        run_match(@players, max_game_count, side_having_first_service)
        $logger.info "Match ended, asking for rematch"
        @score_board.display('Y', 'N', effect: :blink)
        @last_activity_at = Time.now
        break if @input.get.right?

        @last_activity_at = Time.now
        @players = @players.reverse
        $logger.info "Starting rematch"
      end
    end
  end

  private

  def ask_for_players
    selected_players = {left: nil, right: nil}
    displayed_players = {left: -1, right: -1}

    while selected_players.values.compact.size < 2
      %i[left right].each do |side|
        displayed_players[side] += 1
        displayed_players[side] %= 10
      end

      @score_board.display(selected_players[:left] || displayed_players[:left], selected_players[:right] || displayed_players[:right])
      sleep PLAYER_SELECTION_DELAY

      input = @input.get(block: false)
      %i[left right].each do |side|
        if input && input.normal? && input.side == side
          selected_players[side] = displayed_players[side]
          $logger.info "Chosen player #{side}: #{selected_players[side]}"
        end
      end
    end
    selected_players.values_at(:left, :right)
  end

  def ask_for_max_game_count
    @score_board.display(3, 5, effect: :blink)
    @input.get.left? ? 3 : 5
  end

  def ask_for_side_having_first_service
    @score_board.display('SERVICE ', 'SERVICE ', effect: :scroll)
    @input.get.left? ? :left : :right
  end

  def run_match(players, max_game_count, side_having_first_service)
    @match = Match.new(side_having_first_service: side_having_first_service, max_game_count: max_game_count)

    loop do
      update_score_board(@match)

      if @match.match_finished?
        data = {
          token: OFFICE_API_TOKEN,
          source: "tischtennisdisplay",
          type: "TableTennisResultDataItem",
          payload: {
            player1: players[0],
            player2: players[1],
            winner: players[@match.winner - 1],
            games: @match.games.map{ |g| {p1_score: g.p1_score, p2_score: g.p2_score} },
          },
        }
        HTTParty.post OFFICE_API_URL, body: data
      end

      c = @input.get
      @last_activity_at = Time.now
      break if @match.match_finished?
      if c.undo?
        @match.undo
      else
        @match.handle_input(c)
      end
    end
  end

  def update_score_board(match)
    options =
      if match.match_finished?
        {effect: :rotate_ccw, side: match.winner_side}
      elsif match.game_finished?
        {effect: :rotate_cw, side: match.game_winner_side}
      elsif match.waiting_for_final_game_switching_of_sides?
        {effect: :switch_over}
      else
        {effect: :flash_twice_after_delay, side: match.side_having_service}
      end
    left = match.score_for_side(:left) unless match.match_finished? && match.winner_side == :right
    right = match.score_for_side(:right) unless match.match_finished? && match.winner_side == :left
    @score_board.display(left, right, **options)
  end
end

if $0 == __FILE__
  if ARGV[0] == "pi"
    $logger = Logger.new(STDERR)
    $logger.formatter = ->(severity, _datetime, _progname, msg){ "TTD -- #{severity} #{msg}\n" }
    require_relative "untroubled_pi_piper"
    require_relative "button_input"
    require_relative "score_board"
    input = ButtonInput.new(PINS[:left_button_pin], PINS[:right_button_pin])
    score_board = ScoreBoard.new(P1_SHIFT_REGISTER, P2_SHIFT_REGISTER, PINS[:clock_pin])
  elsif ARGV[0] == "pi-keyboard"
    $console_logdev = StringIO.new
    $logger = Logger.new($console_logdev)
    require_relative "untroubled_pi_piper"
    require_relative "console_input"
    require_relative "score_board"
    input = ConsoleInput.new
    score_board = ScoreBoard.new(P1_SHIFT_REGISTER, P2_SHIFT_REGISTER, PINS[:clock_pin])
  else
    $console_logdev = StringIO.new
    $logger = Logger.new($console_logdev)
    require_relative "console_input"
    require_relative "console_score_board"
    input = ConsoleInput.new
    score_board = ConsoleScoreBoard.new
  end

  at_exit do
    score_board.display(nil, nil)
  end

  Main.new(input, score_board).run
end
