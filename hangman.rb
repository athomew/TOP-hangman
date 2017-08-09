require 'yaml/store'
store = YAML::Store.new("hangman-games.pstore")

class Game
  attr_reader :guessed, :wrong_guesses, :word, :right_guesses

  def initialize
    @word = generate_word
    @guessed = []
    @right_guesses = []
    @wrong_guesses = 0
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

# The game logic

puts "Welcome to hangman: the game where losing means someone else dies!"
puts "Would you like to load a past game?"
