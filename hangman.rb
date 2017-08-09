require 'yaml'

class Game
  attr_reader :guessed, :wrong_guesses, :word, :right_guesses
  attr_accessor :save_name

  def initialize
    @word = generate_word
    @guessed = []
    @right_guesses = []
    @wrong_guesses = 0
    @save_name = "new-save"
  end

  def generate_word
    dictionary = File.read('dictionary.txt')
    words = dictionary.scan(/\w+/)
    words.select! { |word| word.length >= 5 && word.length <=12 }
    words.map! { |word| word.downcase }
    word = words[rand(0..(words.length - 1))]
    return word
  end

  def make_guess(letter)
    unless @guessed.include? letter
      @guessed.push(letter)

      if (@word.include? letter)
        @word.split("").each_with_index do |l, i|
          @right_guesses.push(i) if (letter == l)
        end
      else
        @wrong_guesses += 1
      end
    end
  end

  def word_guessed?
    result = @right_guesses.sort == (0..(@word.length - 1)).to_a
  end
end

def save game
  serialised_game = YAML::dump(game)
  save_file = File.open("saved_games.yaml", 'w')
  save_file.puts serialised_game
  save_file.close
end

def load
  save_file = File.open("saved_games.yaml", "r")
  game = YAML::load(save_file.read)
  save_file.close
  return game
end

def word_status game
  result = ""
  game.word.length.times do |i|
    if (game.right_guesses.include? i)
      result << game.word[i]
      result << " "
    else
      result << "_ "
    end
  end

  return result
end

def already_guessed game
  result = "Already guessed:"
  game.guessed.each { |x| result.concat(" #{x}") }

  return result
end


def display_hangman guesses
  case guesses
  when 6
    puts " ____  "
    puts " |   o "
    puts " |  /|\\"
    puts " |  / \\"
    puts " |     "
    puts " ------"
  when 5
    puts " ____  "
    puts " |   o "
    puts " |  /|\\"
    puts " |  /   "
    puts " |     "
    puts " ------"
  when 4
    puts " ____  "
    puts " |   o "
    puts " |  /|\\"
    puts " |     "
    puts " |     "
    puts " ------"
  when 3
    puts " ____  "
    puts " |   o "
    puts " |  /| "
    puts " |     "
    puts " |     "
    puts " ------"
  when 2
    puts " ____  "
    puts " |   o "
    puts " |   | "
    puts " |     "
    puts " |     "
    puts " ------"
  when 1
    puts " ____  "
    puts " |   o "
    puts " |     "
    puts " |     "
    puts " |     "
    puts " ------"
  when 0
    puts " ____  "
    puts " |     "
    puts " |     "
    puts " |     "
    puts " |     "
    puts " ------"
  end
end

# The game logic


puts "\nWelcome to hangman: the game where losing means someone else dies!"
game = Game.new

while (true)
  puts "\nWould you like to load a past game? (Y/N)"
  puts "\n"
  want_to_load = gets.chomp.downcase

  if (want_to_load == "y")
    game = load
    "Game loaded!"
    break
  elsif (want_to_load == "n")
    "Alright. Starting a new game!"
    break
  else
    puts "Unknown command."
  end
end

puts "\nIn order to make a guess, type in a letter."
puts "If at any point you want to save, just type 'save'."
puts "If at any point you want to quit, just type 'quit'"

until(game.word_guessed? || (game.wrong_guesses == 6))
  display_hangman (game.wrong_guesses)

  puts "\n"

  puts word_status game

  puts "\n"

  puts already_guessed game

  puts "\n"

  input = gets.chomp.downcase
  if (input =~ /^[a-z]$/)
    game.make_guess(input)
  elsif (input == "save")
    save game
  elsif (input == "quit")
    exit
  else
    puts "Unknown command."
  end
end

if (game.word_guessed?)
  puts "\n"

  puts word_status game

  puts "\nCongratulations! You've won!"
else
  display_hangman game.wrong_guesses
  puts "\nI'm sorry. The correct word was '#{game.word}'  ."
end
