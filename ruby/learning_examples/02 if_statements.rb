# Created for the codecademy course "Learn Ruby".
# I wrote all the code myself while it gave varying levels of guidance.
print "Please enter a string: "
user_input = gets.chomp
user_input.downcase!

if user_input.include?("s") # You can include 'then' here but it's optional
  user_input.gsub!(/s/, "th") # Regex substitution
else
  puts "Your string didn't contain an 's'"
end

print "Your new string: #{user_input}"