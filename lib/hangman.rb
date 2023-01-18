require 'yaml'

module Word
  def self.generate_word
    file_of_words = File.open("google-10000-english-no-swears.txt", "r")

    #select only 5 to 12 letter words
    list_of_words = file_of_words.select do |word|
      word = word.strip!
      word.length >= 5 && word.length <= 12
    end
  
    #to get a random word
    word = list_of_words.sample
  end

  def self.create_blanks(word)
    arr_of_blanks = Array.new(word.length, "_")
  end

  def self.show_word(word)
    puts "The word to guess was: #{word}"
  end
end

module Display
  def self.before_guess
    print "\nEnter a letter to guess the word: "
  end
    
  def self.wrong_guess(tries)
    puts "\nWrong! You have #{tries} tries left"
  end

  def self.correct_guess(tries)
    puts "You got it! You have #{tries} tries left"
  end

  def self.welcome
    puts %{
      Welcome to Hangman!
      The word to be guessed has been created...
    }
    print "Enter your name: "
  end

  def self.instructions
    puts "You have 12 tries to guess the word"
    puts "If more than one letter is entered, only the first one will be recognized"
  end

  def self.lose
    puts "You failed! Thanks for playing."
  end

  def self.win
    puts "You Win! Congratulations!"
  end

  def self.save?
    puts "Would you like to save your progress? 'Y' or 'N':"
  end
end

class Player
  attr_reader :name
  attr_accessor :tries
  def initialize(name)
    @name = name
    @tries = 12
  end

  def guess
    guess_char = gets.chomp.downcase[0]
  end

  def win?(guess_arr, word)
    guess_arr.join == word
  end

  def save(current_word, blank_arr)
    input = gets.chomp[0].downcase

    until ["y","n"].include?(input)
      puts '"y" or "n" only please'
      input = gets.chomp[0].downcase
    end
    
    if input == "y"
      File.open("save_file.yaml", "w") do |file|
        file.write YAML.dump({
          :name => @name,
          :tries =>@tries,
          :word =>current_word,
          :blanks => blank_arr
        })
      end
    end
  end
end

module GameLoop
  include Word
  include Display

  word_in_play = Word.generate_word
  blanks = Word.create_blanks(word_in_play)
  Display.welcome
  player = Player.new(gets.chomp)
  Display.instructions
  
  Word.show_word(word_in_play)

  player.tries.times do
    Display.before_guess
    guess_char = player.guess
    player.tries -= 1

    if word_in_play.include?(guess_char)
      word_in_play.split("").each_with_index do |letter, idx|
        if letter == guess_char
          blanks[idx] = letter
        end
      end
      Display.correct_guess(player.tries)
      print "\n#{blanks}\n"
      break if player.win?(blanks, word_in_play)
      Display.save?
      player.save(word_in_play, blanks)
    else
      Display.wrong_guess(player.tries)
      print "\n#{blanks}\n"
      Display.save?
      player.save(word_in_play, blanks)
    end
  end

  if player.win?(blanks, word_in_play)
    Display.win
    Word.show_word(word_in_play)
  else
    Display.lose
    Word.show_word(word_in_play)
  end
end
