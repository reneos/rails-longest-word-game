require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    reset if params[:reset]
    @letters = generate_grid
    session[:total] ||= 0
    session[:played] ||= 0
    @played = session[:played]
    @total_score = session[:total]
  end

  def reset
    session[:total] = 0
    session[:played] = 0
  end

  def score
    @letters = params[:letters].split(' ')
    @answer = params[:answer]
    @valid = valid_answer?(@answer.upcase, @letters)
    @score = @valid ? calc_score(@answer) : 0
    tally_total(@score)
    session[:played] += 1
  end

  def generate_grid
    abc = ('A'..'Z').to_a
    letters = []
    9.times { letters << abc.sample }
    return letters if letters.join.count('AEIOU').positive?

    generate_grid
  end

  def valid_answer?(word, letters)
    word?(word) && valid_letters?(word, letters)
  end

  def word?(word)
    url = "https://wagon-dictionary.herokuapp.com/#{word}"
    content = open(url).read
    result = JSON.parse(content)
    result['found']
  end

  def valid_letters?(word, letters)
    word.chars.uniq.all? { |char| word.count(char) <= letters.count(char) }
  end

  def calc_score(word)
    word.length
  end

  def tally_total(score)
    session[:total] += score
  end
end
