#! /usr/bin/env ruby

require 'pg'
require 'date'
require 'io/console'

class ExpenseData
  def initialize
    @connection = PG.connect(dbname: "expenses")
  end
  
  def add_expense(amount, memo)
    date = Date.today
    sql = <<-SQL
    INSERT INTO expenses (amount, memo, created_on)
      VALUES ($1, $2, $3);
    SQL
    @connection.exec_params(sql, [amount, memo, date])
  end
  
  def delete_all_expenses
    @connection.exec("DELETE FROM expenses;")
    puts "All expenses have been deleted."
  end
  
  def delete_expense(id)
    result = select_expense_at(id)
    
    sql = "DELETE FROM EXPENSES WHERE id = $1;"
    @connection.exec_params(sql, [id])
    
    puts "The following expense has been deleted:"
    display_expenses(result)
  end
  
  def list_expenses
    result = @connection.exec("SELECT * from expenses")
    
    display_rows(result)
    display_expenses(result) if result.ntuples > 0
  end
  
  def search_expenses(item)
    sql = "SELECT * FROM expenses WHERE memo ILIKE $1;"
    result = @connection.exec_params(sql, ["%#{item}%"])
    display_rows(result)
    display_expenses(result) if result.ntuples > 0
  end
  
  def select_expense_at(id)
    sql = "SELECT * FROM expenses WHERE id = $1"
    @connection.exec_params(sql, [id])
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
  
  def display_rows(result)
    total_rows = result.ntuples
    case total_rows
    when 0 then puts "There are no expenses."
    when 1 then puts "There is 1 expense."
    else        puts "There are #{total_rows} expenses."
    end
  end
  
  def display_expenses(result)
    total_cost = calculate_total(result)
    
    result.each do |tuple|
      columns = [ tuple["id"].rjust(3),
                  tuple["created_on"].rjust(10),
                  tuple["amount"].rjust(12),
                  tuple["memo"] ]
    
      puts columns.join(" | ")
    end
    
    puts "-" * 50
    puts "Total" + total_cost.to_s.rjust(26)
  end
  
  def calculate_total(result)
    total = result.inject(0) { |memo, t| t["amount"].to_f + memo }
    '%.2f' % total
  end
  
  def id_exists?(id)
    sql = "SELECT $1 IN (select id from expenses);"
    result = @connection.exec_params(sql, [id])
    result.values.first.first == 't'
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
      @db_session.display_help
    when "list"
      @db_session.list_expenses
    when "add"
      amount = args[1]
      memo = args[2]
      abort "You must provide a valid amount and memo." unless valid_add_input?(args)
       @db_session.add_expense(amount, memo)
    when "search"
      item = args[1]
      abort "You must provide a search term." unless item
      @db_session.search_expenses(item)
    when "delete"
      id = args[1]
      abort "There is no expense with the id '#{id}'." unless valid_id?(id)
      @db_session.delete_expense(id)
    when "clear"
      @db_session.delete_all_expenses if valid_clear_input?
    end
  end
  
  def valid_id?(id)
    @db_session.id_exists?(id)
  end
  
  def valid_add_input?(args)
    args[0] == 'add' &&
     args[1].to_f > 0.0 &&
     args.size == 3
  end
  
  def valid_clear_input?
    puts "This will remove all expenses. Are you sure? (y/n)"
    answer = $stdin.getch
    answer == 'y'
  end
end

CLI.new.run(ARGV)