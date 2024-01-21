# Created for the codecademy course "Learn Ruby".
# I wrote all the code myself while it gave varying levels of guidance.
class Computer # Create a class
  @@users = Hash.new # 2 @s at start of variable name means a class variable (not per instance)
  def initialize(username, password) # initiali*z*e :(
    @username = username # 1 @ means instance variable
    @password = password
    @files = Hash.new

    @@users[username] = password
  end

  def create(filename)
    time = Time.now # Get current time.
    @files[filename] = time
    puts "#{@username} Created #{filename} at #{time}"
  end

  def Computer.get_users # Static method (One not tied to any instance)
    @@users # Return omitted as it is not needed.
  end
end

my_computer = Computer.new("admin", "admin") # Don't use this as a password.

class Smartphone < Computer; end # Inheritance. Wasn't needed in any of the examples i did.