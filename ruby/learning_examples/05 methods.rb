# Created for the codecademy course "Learn Ruby".
# I wrote all the code myself while it gave varying levels of guidance.
def alphabetize(arr, rev=false) # Very similar to python
  arr.sort!
  arr.reverse! if rev # Conditional. Only reverses if rev is true.
  return arr # Return is optional here (it returns the last expression) but left in for clarity.
end

numbers = [1,5364, 123]
puts alphabetize(numbers, true)