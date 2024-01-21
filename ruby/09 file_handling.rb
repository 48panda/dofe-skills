file = File.new "test_for_09.txt" # open file
text = file.read # Read all the text from the file.
file.close # Close the file now the text has been read.

puts text
puts # Add another newline.
print "What's your name? " # print = no newline
name = gets.chomp # Chomp removes newline at end.

time = Time.now.to_s # current time cast to string.
time = time.split("+")[0] # Remove the timezone thingy

file = File.new("test_for_09.txt", "a") # a for append
file.syswrite "#{name} was here at #{time}\n" # Add newline at end.
file.close # Close the file.

puts "Appended time #{time} to file!"