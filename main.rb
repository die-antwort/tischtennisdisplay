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

SPREADSHEET_ID = ENV['SS_ID']
SPREADSHEET_TOKEN = ENV['SS_TOKEN']

def postToSpreadsheet(data)
  HTTParty.post("https://sheets.googleapis.com/v4/spreadsheets/#{SPREADSHEET_ID}/values/A1:append?insertDataOption=INSERT_ROWS&valueInputOption=RAW&alt=json", :headers => { "Content-Type" => "application/json", "Authorization" => "Bearer #{SPREADSHEET_TOKEN}"}, :body => { values: [data]}.to_json)
end

class Main
  attr_reader :score_board, :match

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
    $logger.info "Starting up"
    @input.get
    $logger.info "Starting match"
    @last_activity_at = Time.now
    players = ask_for_players
    max_game_count = ask_for_max_game_count
    side_having_first_service = ask_for_side_having_first_service
    @match = Match.new(side_having_first_service: side_having_first_service, max_game_count: max_game_count)

    loop do
      update_score_board(@match)
      c = @input.get
      @last_activity_at = Time.now
      break if @match.match_finished?
      if c.undo?
        @match.undo
      else
        @match.handle_input(c)
      end
    end

    postToSpreadsheet([players[0], players[1], Time.new, { left: players[1], right: players[0]}[@match.winner_side]])

    $logger.info "Match ended, exiting"
  end

  private

  def ask_for_players
    players = [nil, nil]
    players_select = [nil, nil]
    @score_board.display('P', 'P', effect: :blink)

    while players.compact.size < 2
      input = @input.get
      players_index = { left: 0, right: 1}[input.side]

      if input.normal?
        players_select[players_index] = players_select[players_index].to_i + 1
        players_select[players_index] = players_select[players_index] % 10
      end

      if input.undo?
        other_players_index = (players_index + 1) % players.length
        players[players_index] = players_select[players_index] if players[other_players_index] != players_select[players_index]
      end

      display_options = {}

      blink_left = players_select[0] == nil || players[0] != nil
      blink_right = players_select[1] == nil || players[1] != nil

      display_options.merge!({ effect: :blink }) if !players_select.all? || players.any?
      display_options.merge!({ side: :left }) if blink_left && !blink_right
      display_options.merge!({ side: :right }) if blink_right && !blink_left

      @score_board.display(players_select[0] ? players_select[0] : 'P', players_select[1] ? players_select[1] : 'P', **display_options)
    end

    @score_board.display(' ', ' ', effect: :rotate_ccw)
    sleep(2)

    players
  end

  def ask_for_max_game_count
    @score_board.display(3, 5, effect: :blink)
    @input.get.left? ? 3 : 5
  end

  def ask_for_side_having_first_service
    @score_board.display('SERVICE ', 'SERVICE ', effect: :scroll)
    @input.get.left? ? :left : :right
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
