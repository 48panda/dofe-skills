# Created for the codecademy course "Learn Ruby".
# I wrote all the code myself while it gave varying levels of guidance.
movies = {
  movie_1: 3
}

puts "What do you want to do? "
choice = gets.chomp

case choice # Goes to the when statement matching choice or else if no match
  when "add"
    puts "What is the title to add? "
    title = gets.chomp.to_sym # To symbol (Basically just an immutable string which is faster)
    if !movies[title].nil? then # if value is not nil, it exists
      puts "Already exists!"
    else
      puts "What is the rating of it? "
      rating = gets.chomp.to_i # to_i converts to integer
      movies[title] = rating
      puts "Added!"
    end

  when "update"
    puts "What is the title to update? "
    title = gets.chomp.to_sym

    if movies[title].nil? then
      puts "Does not exist!"
    else
      puts "Enter a new rating"
      rating = gets.chomp.to_i
      movies[title] = rating
    end

  when "display"
    movies.each do |movie, rating| # Iterate over each movie
      puts "#{movie}: #{rating}"
    end

  when "delete"
    puts "What is the title to delete? "
    title = gets.chomp.to_sym
    if movies[title].nil? then
      puts "movie does not exist"
    else 
      movies.delete(title) # Delete method. Brackets not needed but added for clarity
    end

  else
    puts "Error!"
end