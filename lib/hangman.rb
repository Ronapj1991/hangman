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
  end

  def self.instructions(tries_num)
    puts "You have #{tries_num} tries to guess the word"
    puts "If more than one letter is entered, only the first one will be recognized"
    puts "To exit the game, press (Ctrl + C)"
    puts "Goodluck!"
  end

  def self.lose
    puts "You failed! Thanks for playing."
  end

  def self.win
    puts "You Win! Congratulations!"
  end

  def self.save?
    puts "Would you like to save your progress?"
  end

  def self.load?
    puts "You can load a progress from a previous save."
    puts "Would you like to do that?"
  end

  def self.already_guessed
    puts "That letter has been guessed. Try a different one"
  end
end

class Player
  attr_accessor :tries
  def initialize
    @tries = 12
  end

  def guess
    guess_char = gets.chomp.downcase[0]
  end

  def win?(guess_arr, word)
    guess_arr.join == word
  end

  def save(answer, current_word, blank_arr)
    if answer == "y"  
      File.open("save_file.yaml", "w") do |file|
        file.write YAML.dump({
          :tries =>@tries,
          :word =>current_word,
          :blanks => blank_arr
        })
      end
    end
  end

  def self.load_hash(answer)
    if answer == "y"
      data = YAML.load(File.read("save_file.yaml"))
    end
  end
end

module GameLoop
  include Word
  include Display

  Display.load?
  load_answer = gets.chomp[0].downcase 
  
  until ["y","n"].include?(load_answer)
    puts '"y" or "n" only please'
    load_answer = gets.chomp[0].downcase
  end
  
  load_game = Player.load_hash(load_answer)
  

  if load_answer == "y"  
    word_in_play = load_game[:word]
    blanks = load_game[:blanks]
    player = Player.new()
    player.tries = load_game[:tries]

  else
    word_in_play = Word.generate_word
    blanks = Word.create_blanks(word_in_play)
    player = Player.new()
  end

  Display.welcome
  Display.instructions(player.tries)
  
  #Word.show_word(word_in_play)
  print "\n#{blanks}\n"

  while (player.tries > 0) do
    Display.before_guess
    guess_char = player.guess
    player.tries -= 1

    if blanks.include?(guess_char)
      Display.already_guessed
      player.tries += 1
    
    elsif word_in_play.include?(guess_char)
      word_in_play.split("").each_with_index do |letter, idx|
        if letter == guess_char
          blanks[idx] = letter
        end
      end
      Display.correct_guess(player.tries)
      print "\n#{blanks}\n"
      break if player.win?(blanks, word_in_play)
      Display.save?
      save_answer = gets.chomp[0].downcase
      
      until ["y","n"].include?(save_answer)
        puts '"y" or "n" only please'
        save_answer = gets.chomp[0].downcase
      end
      
      player.save(save_answer, word_in_play, blanks)

    else
      Display.wrong_guess(player.tries)
      print "\n#{blanks}\n"
      Display.save?
      save_answer = gets.chomp[0].downcase
      
      until ["y","n"].include?(save_answer)
        puts '"y" or "n" only please'
        save_answer = gets.chomp[0].downcase
      end
      
      player.save(save_answer, word_in_play, blanks)
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