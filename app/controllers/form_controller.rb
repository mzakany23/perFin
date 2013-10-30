
class FormController < ApplicationController
  @@word_list = ['ELECTRONIC']

  def index

  end

  def file_upload
  	@file = params[:file]

    @rows = {
      found:  [],
      unfound: []
    }

    File.foreach(@file.path) do |line|
      word_found = false

      @@word_list.each do |word|
        if line.include?(word)
          date = /(?<Month>\d{1,2})\D(?<Day>\d{2})\D(?<Year>\d{4})/.match(line).to_s
          transaction = /(?<transaction>)#{word}/.match(line).to_s
          amount =/-*(?<dollars>\d+)\.(?<cents>\d+)/.match(line).to_s.to_f.round(2)

          @rows[:found] << {
            date: date,
            transaction: transaction,
            amount: amount
          }

          word_found = true
        end
      end

      if !word_found
        date = /(?<Month>\d{1,2})\D(?<Day>\d{2})\D(?<Year>\d{4})/.match(line).to_s
        transaction = /(?<Middle>)".*"/.match(line).to_s
        amount =/-*(?<dollars>\d+)\.(?<cents>\d+)/.match(line).to_s.to_f.round(2)  
        
        @rows[:unfound] << {
          date: date,
          transaction: transaction,
          amount: amount
        }
      end
    end

    @found = @rows[:found].sort_by{|a,b,c| a[:transaction]}
    @unfound = @rows[:unfound].sort_by{|a,b,c| a[:transaction]}
    @sorted_found = sort_file_upload(@@word_list,@found)
  
      
    render 'test_view'
  end

  def sort_file_upload(list,transaction)
    @sorted_hash = {}
    @arr = @sorted_hash

    list.each do |word|
      @arr[word] = []
      transaction.each do |trans|
        if trans[:transaction] == word
          @arr[word] << {
            date: trans[:date],
            transaction: trans[:transaction],
            amount: trans[:amount].to_s.to_f.round(2)
          }
        end
      end
    end
    return @sorted_hash
  end


end
