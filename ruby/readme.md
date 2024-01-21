# things i've learnt* about ruby
*not a complete list

* Methods may be called without brackets if it has 0-1 arguments.

* Methods names may finish with ?, ! or =
    * ? denotes that it returns a boolean
    * ! denotes that it modifies the variable in-place
    * = denotes that it sets a method within the object
    * Methods with an equals will be callled even if there's a space between the equals and the rest of the name. e.g. `a.b = c` actually calls the method `b=` of a with a parameter of c.

* Methods may also be called with one block argument.
    ~~~
    5.times do
        puts "Hello!"
    end
    ~~~
    or
    ~~~
    5.times {
        puts "Hello!"
    }
    ~~~
    Both print Hello! 5 times. It is calling the method times of 5 with the code block as an argument.