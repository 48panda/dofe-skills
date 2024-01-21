# Created for the codecademy course "Learn Ruby".
# I wrote all the code myself while it gave varying levels of guidance.
puts "Input your text here: "
text = gets.chomp

words = text.split

frequencies = Hash.new(0) # Hash is similar to python dictionaries.
words.each do |word| # 0 is the default value
  frequencies[word] += 1
end

frequencies = frequencies.sort_by do |word, freq| # Sorts by frequency
  freq
end
frequencies.reverse! # Reverses the sorted hash in place
frequencies.each do |word, freq| # Prints each word
  puts "#{word} #{freq}"
end