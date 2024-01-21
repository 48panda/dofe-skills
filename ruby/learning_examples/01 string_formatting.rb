# Created for the codecademy course "Learn Ruby".
# I wrote all the code myself while it gave varying levels of guidance.
print "What's your first name? " # Print prints to console without a newline.
first_name = gets.chomp # Chomp takes the newline off the end of the string.
first_name.capitalize! # "! means do in-place"

print "What's your last name? "
last_name = gets.chomp
last_name.capitalize!

print "What's your city? "
city = gets.chomp
city.capitalize!

print "What's your state? "
state = gets.chomp
state.upcase!

#    "#{var}" puts the value of var into the string
puts "Your name is #{first_name} #{last_name}. Your city is #{city}, #{state}"
# puts adds a newline after the string