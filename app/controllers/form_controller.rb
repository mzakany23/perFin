require 'date'
require 'csv'

class FormController < ApplicationController
  WORDLIST = ['ELECTRONIC', 'PAYPAL']

  def add_word_to_list  
    upload_word = params[:upload]
    WORDLIST.push(upload_word)
  end

  #two variables that are used in the view
  # 1. @grouped_labeled_transactions is the variable that carries an array of values per each word
  # 2. @sums is the variable for the @grouped_labeled_transactions amounts: key value 

  def index

  end

  def file_upload

    @sum  = 0

  	file = params[:file]
    rows = {
      labeled_transaction:  [],
      unlabeled_transaction: []
    }
    @sums = {}

    WORDLIST.each do |word|
      @sums[word.to_sym]
    end

    CSV.foreach(file.path, row_sep: :auto, headers: true) do |row|
      word_found = false
      row_hash = row.to_hash 
      ap row_hash
      formatted_row = {
        date: Date.strptime(row_hash["Date"], '%m/%d/%Y'),
        transaction: row_hash["Description"],
        amount: row_hash["Amount"].to_f
        }

      WORDLIST.each do |word|
        if row_hash["Description"].include?(word)
          rows[:labeled_transaction] << formatted_row
          word_found = true
        end
      end

      if !word_found
        rows[:unlabeled_transaction] << formatted_row
      end
    end

    labeled_transaction = rows[:labeled_transaction].sort_by{|a,b,c| a[:transaction]}
    @unlabeled_transaction = rows[:unlabeled_transaction].sort_by{|a,b,c| a[:transaction]}
    @grouped_transactions = grouped_labeled_transactions(WORDLIST, labeled_transaction)

    render 'test_view'
  end

  def grouped_labeled_transactions(word_list,labeled_transactions)
    grouped_labeled_transactions = {}
    word_list.each do |word|
      key = word.to_sym
      grouped_labeled_transactions[key]= []

      labeled_transactions.each do |labeled_transaction|
        grouped_labeled_transactions[key] << labeled_transaction if labeled_transaction[:transaction].include?(word)
      end
    end
    grouped_labeled_transactions
  end


end
