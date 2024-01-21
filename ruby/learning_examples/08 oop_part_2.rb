# Created for the codecademy course "Learn Ruby".
# I wrote all the code myself while it gave varying levels of guidance.
class Account
    attr_reader :name # Make a method called name for reading name
    attr_reader :balance
    attr_writer :name # Makes a method called name= for setting name
    #attr_accessor combines both of these.
    def initialize(name, balance=100)
      @name = name
      @balance = balance
    end
    public
    def display_balance(pin_number)
      return pin_error unless pin_number == @pin
      puts "Balance: $#{@balance}." if pin_number == @pin
    end
    def withdraw(pin_number, amount)
      return pin_error unless pin_number == @pin
      @balance -= amount
      puts "Withdrew $#{amount}. New balance: $#{@balance}."
    end
    private
    def pin
      @pin = 1234
    end
    def pin_error
      puts "Access denied: incorrect PIN."
    end
  end
  
  checking_account = Account.new("Test", 10)