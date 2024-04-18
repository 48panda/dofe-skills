require 'gosu'
require 'json'

class Vector
    # A vector. Can have any number of rows.
    # Can be added/subtracted from each other
    # Can be multiplied / divided by a scalar
    # Can be dot producted together
    attr_reader :elems
    def initialize(elems)
        @elems = elems # Array of elements
    end

    def dot(other) # Dot product of vectors
        total = 0
        other = other.elems if other.is_a? Vector # If other is a vector, get its elements as an array
        @elems.zip(other) # Group the elements into pairs
        .map{|arr| arr[0] * arr[1]} # Product those pairs together
        .each{|val| total += val} # Sum each of these
        return total
    end

    def +(other)
        other = other.elems if other.is_a? Vector # If other is a vector, get its elements as an array
        return Vector.new @elems.zip(other) # Group the elements into pairs
        .map{|arr| arr[0] + arr[1]} # Add those pairs
    end
    def -(other)
        other = other.elems if other.is_a? Vector
        return Vector.new @elems.zip(other) # Group the elements into pairs
        .map{|arr| arr[0] - arr[1]} # Subtract those pairs
    end
    def /(other) # Divide all elements by other.
        return Vector.new @elems.map{|arr| arr / other}
    end
    def *(other) # Multiply all elements by other.
        return Vector.new @elems.map{|arr| arr * other}
    end
    def mag
        Math.sqrt(self.dot self) # Get the magnitude of the vector (sqrt of it dot itself)
    end

    def to_s
        elems.to_s # stringify method for debugging
    end

    def x
        @elems[0] # Convenience methods for low-dimension vectors.
    end
    def y
        @elems[1] # Convenience methods for low-dimension vectors.
    end
    def z
        @elems[2] # Convenience methods for low-dimension vectors.
    end
end

CUBE_ANG_VEL = 15 #radians/sec of the dice rotation
CUBE_REL_FRIC = 0.04 # Dice friction - changes how quickly it slows down after pressing space
def random_unit_vec
    theta = rand * 2 * Math::PI # Choose random angle on x y plane
    z = rand * 2 - 1 # choose random z
    # See: https://math.stackexchange.com/a/44691
    return Vector.new([Math.sqrt(1-z*z)*Math.cos(theta), Math.sqrt(1-z*z)*Math.sin(theta), z])
end

class Matrix
    # Matrix class
    # Can dot with other matrices or vectors
    # Implemented as an array of vectors.
    attr_reader :elems
    def initialize(elems)
        @elems = elems
    end

    def dot(other)
        if other.is_a? Vector then # Dot product with a vector
            return Vector.new @elems.map{|x|x.elems} # Unwrap the vectors in the matrix with an array
            .transpose # Transpose to get arrays of rows
            .map{|x|other.dot x} # Dot product the vector with each row to get the new matrix.
        else
            # Matrix-Matrix multiplications is just multiple Matrix-Vector multiplications
            # So, break down the other matrix into column vectors, multiply by this one
            # then convert back to matrix.
            return Matrix.new other.elems.map{|x|dot x}
        end
    end
end

class Vertex
    # Vertex of a triangle. Has a 3d vector (pos) and a color (col)
    attr_reader :pos
    attr_reader :col
    def initialize(pos, col)
        @pos = pos
        @col = col
    end
end

class Triangle
    # A triangle is 3 vertices which can be rendered.
    # It also has a z vector which determines render order.
    def initialize(v1,v2,v3,z)
        @v1 = v1
        @v2 = v2
        @v3 = v3
        @z = z
    end

    def draw(mat)
        v1 = mat.dot @v1.pos
        v2 = mat.dot @v2.pos
        v3 = mat.dot @v3.pos
        z = mat.dot @z
        # Render the triangle, transformed by a matrix.
        Gosu::draw_triangle(v1.x, v1.y, @v1.col, v2.x, v2.y, @v2.col, v3.x, v3.y, @v3.col, z = z.z)
    end
end

class Line
    # A triangle is 2 vertices which can be rendered.
    # It also has a z vector which determines render order.
    def initialize(v1, v2, z)
        @v1 = v1
        @v2 = v2
        @z = z
    end

    def draw(mat)
        v1 = mat.dot @v1.pos
        v2 = mat.dot @v2.pos
        z = mat.dot @z
        # Render the line, transformed by a matrix.
        Gosu::draw_line(v1.x, v1.y, Gosu::Color::WHITE, v2.x, v2.y, Gosu::Color::WHITE, z = z.z)
    end
end
DOT_SIZE = 0.1 # Size of the dot relative to the dice (1 is a side length)
DOT_NUM = 5 # Number of vertices per dot
class Dot
    # A dot is a dot on a dice.
    def initialize(pos, x, y, z)
        # x, y, z are orthogonal vectors providing a local coordinate space for the vertex creation.
        points = []
        start_angle = rand() * 2 * Math::PI # Randomly offset the dots
        DOT_NUM.times do |i|
            angle = i * 2 * Math::PI / DOT_NUM + start_angle # Calculate the angle for i.
            points.append(Vertex.new(pos + (x * DOT_SIZE * Math.cos(angle)) + (y * DOT_SIZE *  Math.sin(angle)), Gosu::Color::BLACK))
            # Create a vertex at that angle
        end
        # Triangulation.
        @tris = []
        (DOT_NUM - 2).times do |i| # points[0] is the centre point for the triangulation
            # It is a fan triangulation (see: https://en.wikipedia.org/wiki/Fan_triangulation)
            @tris.append(Triangle.new(points[0], points[i+1], points[i+2], z))
        end
    end
    def draw(mat)
        @tris.each{|x|x.draw(mat)} # Draw each triangle
    end
end

def square(verts, num) # Create a dice square from 4 vertices and the number to be shown on the dice.
    z = (verts[0][0].pos + verts[0][1].pos + verts[1][0].pos + verts[1][1].pos) / 4.0
    x = verts[1][0].pos - verts[0][0].pos
    y = verts[0][1].pos - verts[0][0].pos # Define a local coordinate space.
    dots = []
    if num % 2 == 1
        dots.append Dot.new(z * 1.01, x, y, z * 10) # If odd, add dot in the middle
    end
    if num > 1 # If 2,3,4,5,6 add dots on diagonal
        dots.append Dot.new(z * 1.01 + (x + y) * 0.25, x, y, z * 10)
        dots.append Dot.new(z * 1.01 - (x + y) * 0.25, x, y, z * 10)
    end
    if num > 3 # If 4,5,6 add dots on other diagonal
        dots.append Dot.new(z * 1.01 + (x - y) * 0.25, x, y, z * 10)
        dots.append Dot.new(z * 1.01 - (x - y) * 0.25, x, y, z * 10)
    end
    if num > 5 # If 6 add dots along horizontal.
        dots.append Dot.new(z * 1.01 + (x) * 0.25, x, y, z * 10)
        dots.append Dot.new(z * 1.01 - (x) * 0.25, x, y, z * 10)
    end
    t1 = Triangle.new(verts[0][0], verts[0][1], verts[1][1], z) # Create face
    t2 = Triangle.new(verts[0][0], verts[1][0], verts[1][1], z) # Create face
    l1 = Line.new(verts[0][0], verts[0][1], z) # Create outline
    l2 = Line.new(verts[1][0], verts[1][1], z) # Create outline
    l3 = Line.new(verts[0][0], verts[1][0], z) # Create outline
    l4 = Line.new(verts[0][1], verts[1][1], z) # Create outline
    return [t1, t2, l1, l2, l3, l4] + dots
end

def s(n)
    # Converts n, either 0 or 1 to -1 or 1.
    # Used to convert array coordinates of a cube's vertices to
    # render coordinates
    return -1 if n == 0
    return 1
end

def c(n)
    # Converts n, either 0 or 1 to 100 or 200.
    # Used to create a color from the xyz array vertices of the cube.
    return 100 if n == 0
    return 250
end

class Cube # Dice class.
    attr_accessor :released
    attr_accessor :done
    def initialize(textcol, xoffset)
        #vertices[x][y][z] = Vertex.new(Vector.new(s x, s y, s z), Gosu::Color.rgba(c x, c y, c z))
        vertices = [] # temp list of vertices
        @triangles = [] # List of all of the components of the dice. Not all triangles, either triangle, line or dot.
        @ang_vel = random_unit_vec * CUBE_ANG_VEL # Random angular velocity.
        @released = false # Has the dice been rolled yet?
        @done = false # Has the dice rolled and stopped rolling?
        @textcol = textcol # Color for the text
        @xoffset = xoffset # Move the dice left or right on the screen
        2.times do |x| # Loop over x,y,z, make vertices
            verts = []
            2.times do |y|
                vs = []
                2.times do |z|
                    vs.append(Vertex.new(Vector.new([s(x), s(y), s(z)]), Gosu::Color.rgba(c(x), c(y), c(z), 255)))
                end
                verts.append(vs)
            end
            vertices.append(verts)
        end
        # Create 2 faces for each axis.
        2.times do |x|
            @triangles += square vertices[x], 4 - x
        end
        2.times do |y|
            @triangles += square vertices.map{|x|x[y]}, 5 - 3 * y
        end
        2.times do |z|
            @triangles += square vertices.map{|x|x.map{|y|y[z]}}, 6 - 5 * z
        end
    end
    def get_winning_num(m) # Find the face whose normal is closest to the vector towards the camera (the face whose side is closest to facing the camera, so has won)
        one = Vector.new([0,0,1]).dot(m.dot Vector.new([0,0,1]))
        two = Vector.new([0,0,1]).dot(m.dot Vector.new([0,1,0]))
        three=Vector.new([0,0,1]).dot(m.dot Vector.new([1,0,0]))
        four =Vector.new([0,0,1]).dot(m.dot Vector.new([-1,0,0]))
        five =Vector.new([0,0,1]).dot(m.dot Vector.new([0,-1,0]))
        six = Vector.new([0,0,1]).dot(m.dot Vector.new([0,0,-1]))
        maxdot = [one,two,three,four,five,six].max
        return 1 if one == maxdot
        return 2 if two == maxdot
        return 3 if three == maxdot
        return 4 if four == maxdot
        return 5 if five == maxdot
        return 6
    end
    def done?
        return @done
    end
    def draw(t)
        Gosu::translate(@xoffset, 0) do # Translate on the screen.

            if not @done then
                if not @released # Still rolling at full speed.
                    rx, ry, rz = (@ang_vel * t).elems # Calculate rotation angles.
                    if Gosu.button_down? Gosu::KB_SPACE # If space down, the dice is being released.
                        @rot = @ang_vel * t # Store the current rotation (friction means we cant times by time anymore)
                        @released = true
                        @t = t # We need to store the last update time to get a deltatime.
                    end
                else
                    @rot += @ang_vel * (t - @t) # Apply angular velocity
                    @ang_vel *= 1 - CUBE_REL_FRIC * rand # Randomly vary the friction
                    rx, ry, rz = @rot.elems
                    @t = t
                end
            else
                rx, ry, rz = @rot.elems
            end
            sx = Math.sin(rx) # Convenience variables
            cx = Math.cos(rx)
            sy = Math.sin(ry)
            cy = Math.cos(ry)
            sz = Math.sin(rz)
            cz = Math.cos(rz)
            # Matrix for x-axis rotation
            mx = Matrix.new([Vector.new([1,0,0]), Vector.new([0,cx,sx]), Vector.new([0, -sx, cx])])
            # Matrix for y-axis rotation
            my = Matrix.new([Vector.new([cy,0,-sy]), Vector.new([0,1,0]), Vector.new([sy, 0, cy])])
            # Matrix for z-axis rotation
            mz = Matrix.new([Vector.new([cz,sz,0]), Vector.new([-sz,cz,0]), Vector.new([0, 0, 1])])
            m = mx.dot my.dot mz # multiply to get one big transformation matrix
            @triangles.each{|x|x.draw(m)} # Render each component of the dice
            if @done # If done, need to draw the number.
                Gosu::scale(0.01, 0.01) do # un-scale from cube coordinates to screen coordinates
                    @wintxt.draw(-@wintxt.width/2,-@wintxt.height/2,z=100,1,1, color=@textcol) # Draw roll result
                end
            elsif @released and @ang_vel.mag < 0.01 then # Stop if moving quite slowly
                @winner = get_winning_num(m)
                @wintxt = Gosu::Image.from_text(@winner.to_s, 200)
                @done = true
            end
        end
    end
    def value
        @winner
    end
end

class Player
    # Player class
    # Stores information about 1 player
    attr_reader :name
    attr_reader :color
    attr_reader :score
    def initialize(name, color, side)
        @name = name
        @score = 0
        @color = color # The players color (red or blue)
        @side = side # 0 for left, 1 for right, is where name is shown.
        @text = Gosu::Image.from_text(@name, 75) # image with name as text
        @scoretext = Gosu::Image.from_text(@score, 65) # image with score as text
    end

    def score=(newscore)
        # Custom score setter which rerenders scoretext whenever the score changes
        @score = newscore
        @scoretext = Gosu::Image.from_text(@score, 65)
    end

    def draw
        # Draw the name and score in the relevant place
        @text.draw(@side * (1280-@text.width), 0, 10000, 1, 1, @color)
        @scoretext.draw(@side * (1280-@scoretext.width), 100, 10000, 1, 1, @color)
    end
end

class DiceRollWindow # Window used for when the dice is rolling.
    def initialize(player)
        @player = player
        @dice1 = Cube.new(player.color, -4) # Make 2 dice
        @dice2 = Cube.new(player.color, 4) # Make 2 dice
        @dice3 = nil
        @text = Gosu::Image.from_text("Press SPACE to roll the dice", 50) # Text that may be needed.
        @eventext = Gosu::Image.from_text("+10 (Even dice roll)", 50)
        @oddtext = Gosu::Image.from_text("-5 (Odd dice roll)", 50)
        @doubletext = Gosu::Image.from_text("You rolled doubles - Bonus roll!", 50)
        @continuetext = Gosu::Image.from_text("Press SPACE to continue", 50)
        @score = -1 # sum of first 2 dice
        @waitingtoquit=false # end of turn, waiting for space bar.
        @doingdoubles=false # doubles
        @bonus = -1 # bonus dice
        @quitting = false # signals to main class to do next turn.
    end

    def quitting?
        @quitting
    end

    def update
        if @dice1.done? and @dice2.done? and not @waitingtoquit and not @doingdoubles
            # Dice have finished rolling
            # Update state variables to indicate state.
            @score = @dice1.value + @dice2.value
            @waitingtoquit = true unless @dice1.value == @dice2.value
            @doingdoubles = true if @dice1.value == @dice2.value
            # Make bonus dice if needed
            @dice3 = Cube.new(@player.color, 0) if @dice1.value == @dice2.value
            # Update player score.
            @player.score += @score
            @player.score += 10 if @score % 2 == 0
            @player.score -= 5 if @score % 2 == 1
        end
        if @doingdoubles and @dice3.done? and not @waitingtoquit then
            # Bonus dice has rolled
            @waitingtoquit = true
            # Add to score
            @player.score += @dice3.value
        end
        if @waitingtoquit and Gosu::button_down? Gosu::KB_SPACE
            # Signal to quit
            @quitting = true
        end
    end

    def draw
        Gosu::scale(100, 100) do # Scale the cube's coordinate space.
            @dice1.draw(Gosu.milliseconds / 1000.0) # Give the cubes time so they can rotate well.
            @dice2.draw(Gosu.milliseconds / 1000.0)
            @dice3.draw(Gosu.milliseconds / 1000.0) unless @dice3 == nil # Only render if it exists.
        end
        # Roll the dice text until dice are rolled.
        @text.draw(-@text.width/2, 200, 1000,1,1, color=@player.color) unless @dice1.released and @dice2.released

        if @score > 0 # if first dice roll finished
            # Draw odd/even text.
            @eventext.draw(-@eventext.width/2, -350, 1000,1,1, color=@player.color) if @score % 2 == 0
            @oddtext.draw(-@oddtext.width/2, -350, 1000,1,1, color=@player.color) if @score % 2 == 1
            # Draw text to show how to quit.
            @continuetext.draw(-@continuetext.width/2, -250, 1000,1,1, color=@player.color) if @waitingtoquit
            if @doingdoubles
                # Draw text for doubles
                @doubletext.draw(-@doubletext.width/2, -300, 1000,1,1, color=@player.color) unless @dice3.released
                @text.draw(-@text.width/2, -250, 1000,1,1, color=@player.color) unless @dice3.released
            end
        end
    end
end

class LeaderboardWindow # Shown at end of game
    def initialize(leaderboard, winner)
        @leaderboard = leaderboard
        @lbtext = Gosu::Image.from_text("Leaderboard:", 50)
        @texts = Hash.new()
        @winnerindex = 0
        @winner = winner
        @leaderboard.each_with_index do |hash, index| # Find this games winner's index in the leaderboard
            if hash["name"] == winner.name and hash["score"] == winner.score
                @winnerindex = index
            end
        end
        
    end

    def update() end # no updating needed.
    
    def draw
        @lbtext.draw(-200, -300)
        @leaderboard.each_with_index do |hash, index|
            y = index * 75 - 200
            color = Gosu::Color::WHITE
            color = @winner.color if index == @winnerindex # Highlight current winner.
            drawtext(hash["name"], -200, y, color) # Draw name and score
            drawtext(hash["score"], 100, y, color) # Draw name and score
        end
    end

    def drawtext(text, x, y, color)
        if not @texts.key?(text) # "cache" images for efficiency
            @texts[text] = Gosu::Image.from_text(text, 75)
        end
        @texts[text].draw(x, y, 100000, 1, 1, color) # draw image
    end

    def quitting?
        false # never quit (could add score to leaderboard again)
    end
end

class DiceGame < Gosu::Window
  def initialize
    super 1280, 720
    self.caption = "Dice Game"
    print "What is Player 1's name? " # Ask for names
    @player1 = Player.new(gets.chomp, Gosu::Color::RED, 0)
    print "What is Player 2's name? "
    @player2 = Player.new(gets.chomp, Gosu::Color::BLUE, 1)
    @window = DiceRollWindow.new(@player1)
    @turnsleft = 10
  end
  
  def update
    @window.update()
    if @window.quitting? and not Gosu::button_down? Gosu::KB_SPACE # Wait for space to not be down (prevents accidental double presses.)
        @turnsleft -= 1
        if @turnsleft <= 0
            finish # do finish function
        else
            @window = DiceRollWindow.new(@player1) if @turnsleft % 2 == 0 # Swap player.
            @window = DiceRollWindow.new(@player2) if @turnsleft % 2 == 1
        end
    end
  end

  def finish
    winner = @player1 if @player1.score >  @player2.score # Find winner
    winner = @player2 if @player1.score <= @player2.score
    leaderboard = update_leaderboard winner # update leaderboard
    @window = LeaderboardWindow.new(leaderboard, winner) # Display leaderboard
  end
  
  def draw
    translate(640, 360) do
        @window.draw() # Draw current window
    end
    @player1.draw() # Draw player1, player2
    @player2.draw()
  end
end

def update_leaderboard(player)
    rfile = File.new("leaderboard.json", "r")
    json = JSON.parse rfile.read
    rfile.close
    json.append({"name"=> player.name, "score"=> player.score}) # Add new entry to leaderboard
    json = json.sort_by do |hash|
        hash["score"] # Sort the new entry into the list
    end.reverse
    finaljson = json.clone # Store a copy containing this games winner to display
    if json.length > 5
        json.pop # Trim excess entries
    end
    wfile = File.new("leaderboard.json", "w") # Write to file
    wfile.write(json.to_json)
    wfile.close
    return finaljson # return copy containing this games winner
end

DiceGame.new().show() # Start!