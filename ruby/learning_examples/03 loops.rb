# Created for the codecademy course "Learn Ruby".
# I wrote all the code myself while it gave varying levels of guidance.
puts "Enter some text here: "
text = gets.chomp

puts "What to redact? "
redact = gets.chomp

words = text.split(" ")

words.each do |word| # Calls the iterator words.each which calls the block
        #with input parameter word
  if word == redact
    print "REDACTED "
  else
    print word + " "
  end
end