require 'gosu'

class Vector
    attr_reader :elems
    def initialize(elems)
        @elems = elems
    end

    def dot(other)
        total = 0
        other = other.elems if other.is_a? Vector
        @elems.zip(other).map{|arr| arr[0] * arr[1]}.each{|val| total += val}
        return total
    end

    def +(other)
        other = other.elems if other.is_a? Vector
        return Vector.new @elems.zip(other).map{|arr| arr[0] + arr[1]}
    end
    def -(other)
        other = other.elems if other.is_a? Vector
        return Vector.new @elems.zip(other).map{|arr| arr[0] - arr[1]}
    end
    def /(other)
        return Vector.new @elems.map{|arr| arr / other}
    end
    def *(other)
        return Vector.new @elems.map{|arr| arr * other}
    end
    def mag
        Math.sqrt(self.dot self)
    end

    def to_s
        elems.to_s
    end

    def x
        @elems[0]
    end
    def y
        @elems[1]
    end
    def z
        @elems[2]
    end
end

CUBE_ANG_VEL = 15 #rad/sec
CUBE_REL_FRIC = 0.04
def random_unit_vec
    theta = rand * 2 * Math::PI
    z = rand * 2 - 1
    return Vector.new([Math.sqrt(1-z*z)*Math.cos(theta), Math.sqrt(1-z*z)*Math.sin(theta), z])
end

class Matrix
    attr_reader :elems
    def initialize(elems)
        @elems = elems
    end

    def self.identity(size)
        elems = Array.new()
        size.times do |i|
            arr = Array.new(size){0}
            arr[i] = 1
            elems.append(arr)
        end
        return Matrix.new elems
    end

    def dot(other)
        if other.is_a? Vector then
            return Vector.new @elems.map{|x|x.elems}.transpose.map{|x|other.dot x}
        else
            return Matrix.new other.elems.map{|x|dot x}
        end
    end
end

class Vertex
    attr_reader :pos
    attr_reader :col
    def initialize(pos, col)
        @pos = pos
        @col = col
    end
end

class Triangle
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
        Gosu::draw_triangle(v1.x, v1.y, @v1.col, v2.x, v2.y, @v2.col, v3.x, v3.y, @v3.col, z = z.z)
    end
end

class Line
    def initialize(v1, v2, z)
        @v1 = v1
        @v2 = v2
        @z = z
    end

    def draw(mat)
        v1 = mat.dot @v1.pos
        v2 = mat.dot @v2.pos
        z = mat.dot @z
        Gosu::draw_line(v1.x, v1.y, Gosu::Color::WHITE, v2.x, v2.y, Gosu::Color::WHITE, z = z.z)
    end
end
DOT_SIZE = 0.1
DOT_NUM = 5
class Dot
    def initialize(pos, x, y, z)
        points = []
        DOT_NUM.times do |i|
            angle = i * 2 * Math::PI / DOT_NUM
            points.append(Vertex.new(pos + x * DOT_SIZE * Math.cos(angle) + y * DOT_SIZE *  Math.sin(angle), Gosu::Color::BLACK))
        end
        @tris = []
        (DOT_NUM - 2).times do |i|
            @tris.append(Triangle.new(points[0], points[i+1], points[i+2], z))
        end
    end
    def draw(mat)
        @tris.each{|x|x.draw(mat)}
    end
end

def s(n)
    return -1 if n == 0
    return 1
end

def c(n)
    return 100 if n == 0
    return 200
end

def square(verts, num)
    z = (verts[0][0].pos + verts[0][1].pos + verts[1][0].pos + verts[1][1].pos) / 4.0
    x = verts[1][0].pos - verts[0][0].pos
    y = verts[0][1].pos - verts[0][0].pos
    dots = []
    if num % 2 == 1
        dots.append Dot.new(z * 1.01, x, y, z * 10)
    end
    if num > 1
        dots.append Dot.new(z * 1.01 + (x + y) * 0.25, x, y, z * 10)
        dots.append Dot.new(z * 1.01 - (x + y) * 0.25, x, y, z * 10)
    end
    if num > 3
        dots.append Dot.new(z * 1.01 + (x - y) * 0.25, x, y, z * 10)
        dots.append Dot.new(z * 1.01 - (x - y) * 0.25, x, y, z * 10)
    end
    if num > 5
        dots.append Dot.new(z * 1.01 + (x) * 0.25, x, y, z * 10)
        dots.append Dot.new(z * 1.01 - (x) * 0.25, x, y, z * 10)
    end
    t1 = Triangle.new(verts[0][0], verts[0][1], verts[1][1], z)
    t2 = Triangle.new(verts[0][0], verts[1][0], verts[1][1], z)
    l1 = Line.new(verts[0][0], verts[0][1], z)
    l2 = Line.new(verts[1][0], verts[1][1], z)
    l3 = Line.new(verts[0][0], verts[1][0], z)
    l4 = Line.new(verts[0][1], verts[1][1], z)
    return [t1, t2, l1, l2, l3, l4] + dots
end

class Cube
    def initialize(textcol)
        #vertices[x][y][z] = Vertex.new(Vector.new(s x, s y, s z), Gosu::Color.rgba(c x, c y, c z))
        vertices = []
        @triangles = []
        @ang_vel = random_unit_vec * CUBE_ANG_VEL
        @released = false
        @done = false
        @textcol = textcol
        2.times do |x|
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
    def get_winning_num(m)
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
    def draw(t)
        if not @done then
            if not @released
                rx, ry, rz = (@ang_vel * t).elems
                if Gosu.button_down? Gosu::KB_SPACE
                    @rot = @ang_vel * t
                    @released = true
                    @t = t
                end
            else
                @rot += @ang_vel * (t - @t)
                @ang_vel *= 1 - CUBE_REL_FRIC * rand # Randomly vary the friction
                rx, ry, rz = @rot.elems
                @t = t
            end
        else
            rx, ry, rz = @rot.elems
        end
        sx = Math.sin(rx)
        cx = Math.cos(rx)
        sy = Math.sin(ry)
        cy = Math.cos(ry)
        sz = Math.sin(rz)
        cz = Math.cos(rz)
        mx = Matrix.new([Vector.new([1,0,0]), Vector.new([0,cx,sx]), Vector.new([0, -sx, cx])])
        my = Matrix.new([Vector.new([cy,0,-sy]), Vector.new([0,1,0]), Vector.new([sy, 0, cy])])
        mz = Matrix.new([Vector.new([cz,sz,0]), Vector.new([-sz,cz,0]), Vector.new([0, 0, 1])])
        m = mx.dot my.dot mz
        @triangles.each{|x|x.draw(m)}
        if @done 
            Gosu::scale(0.01, 0.01) do
                @wintxt.draw(-@wintxt.width/2,-@wintxt.height/2,z=100,1,1, color=@textcol)
            end
            return
        end
        if @released and @ang_vel.mag < 0.01 then
            @winner = get_winning_num(m)
            @wintxt = Gosu::Image.from_text(@winner.to_s, 200)
            @done = true
        end
    end
end
class Tutorial < Gosu::Window
  def initialize
    super 1280, 720
    self.caption = "Tutorial Game"
    @cube = Cube.new(Gosu::Color::BLUE)
  end
  
  def update
    
  end
  
  def draw
    translate(640, 360) do
        scale(100, 100) do
            @cube.draw(Gosu.milliseconds / 1000.0)
        end
    end
  end
end

Tutorial.new().show()