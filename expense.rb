#! /usr/bin/env ruby

require 'pg'
require 'date'

class ExpenseData
  def initialize
    @connection = PG.connect(dbname: "expenses")
  end
  
  def list_expenses
    result = @connection.exec("SELECT * from expenses")
    result.each do |tuple|
      columns = [ tuple["id"].rjust(3),
                  tuple["created_on"].rjust(10),
                  tuple["amount"].rjust(12),
                  tuple["memo"] ]
    
      puts columns.join(" | ")
    end
  end
  
  def add_expense(amount, memo)
    date = Date.today
    sql = <<-SQL
    INSERT INTO expenses (amount, memo, created_on)
      VALUES ($1, $2, $3);
    SQL
    @connection.exec_params(sql, [amount, memo, date])
  end
end

class CLI
  def initialize
    @db_session = ExpenseData.new
  end
  
  def run(args)
    command = args[0]

    case command
    when nil
      display_help
    when "list"
      @db_session.list_expenses
    when "add"
      amount = args[1]
      memo = args[2]
      abort "You must provide a valid amount and memo." unless valid_add_input?(args)
       @db_session.add_expense(amount, memo)
    end
  end
  
  def display_help
    output = <<-HELP
      An expense recording system
  
      Commands:
  
      add AMOUNT MEMO - record a new expense
      clear - delete all expenses
      list - list all expenses
      delete NUMBER - remove expense with id NUMBER
      search QUERY - list expenses with a matching memo field
    HELP
    
    puts output
  end
  
  def valid_add_input?(args)
    args[0] == 'add' &&
     args[1].to_f > 0.0 &&
     args.size == 3
  end
end

CLI.new.run(ARGV)
