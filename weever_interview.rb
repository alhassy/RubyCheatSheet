# For full documentation and examples, please see
# https://alhassy.github.io/RubyCheatSheet/weever_interview.html

class Robot
  # Robots have two other useful features that one may query.
  attr_reader   :name       # Name of the robot
  attr_accessor :x, :y      # Current location
  attr_reader   :deliveries # Non-empty list of locations it has been to.
                            # A “location” is a hash of two
                            # integers :x, :y.
  # A robot is brought into existence needing only a name.
  def initialize name
    @name         = name
    @x		= 0
    @y		= 0
    @deliveries = [ {x: @x, y: @y} ]
    end
  # Its current location, a pair of integers
  def location
      "(#{@x}, #{@y})"
  end
  def move direction
    case direction
    in :up
      @y += 1
    in :down
      @y -= 1
    in :left
      @x -= 1
    in :right
      @x += 1
    in oops
      raise "#{@name} sees a malformed direction: #{oops}!"\
           "\nCardinal directions are the symbols :up, :down, :left, :right."
    end
    @deliveries << {x: @x, y: @y}
  end
end # Robot class end.

class DistributionsCompany
  attr_accessor :universe   # A mapping of locations-to-robots
  attr_accessor :directions # List of directions
  attr_accessor :robots     # List of directions
  # In Robot#move we were verbose, using pattern matching and error checking.
  # This time, let's forgoe the checks and be terse.
  # That is, a precondition of this method if that
  # ‘arg’ is a string consisting of ^,v,V,<,> .
  def directions= arg
    @directions = arg.split('').map{ |x| {"^" => :up,
                                          "v" => :down, "V" => :down,
                                          "<" => :left, ">" => :right}[x] }
  end
  
  # A precondition of this method is that
  # ‘arg’ is a comma separated string of unique names.
  def robots= arg
    @robots = arg.split(",").map{ |x| Robot.new(x.strip.to_sym) }
  end
  def initialize robots = "robbie", directions = ""
    @universe       = Hash.new([]) # Thus far, every location has vistiors [].
    self.robots     = robots
    self.directions = directions
  
    # Universe dimensions grow with robot movements.
    @X = [0, 0]
    @Y = [0, 0]
    end
  def show
    puts ""
    for row in @Y[1].downto @Y[0] do
      for col in @X[0].upto @X[1] do
        format = if row == 0 and col == 0 then "⟨%s⟩" else " %s " end
        print format % @universe[{x: col, y: row}].length
      end
      puts ""
    end
  end
  # This method carries out a number of directions.
  #
  # step: The number of directional steps to perform; all by default.
  # withmap: Flag to indicate whether a map should be drawn at each stage.
  #          For brevity, this requires that step be non-nil.
  def ship (step: nil, withmap: false)
    # Essentially zipping with a cyclic list
    l = @robots.length                              
    (@directions || []).each_with_index do |d, i|   
  
      # Move the current robot
      r            = @robots[i.modulo(l)]           
      old_location = r.location                     
      r.move(d)
  
      # Update the universe dimensions              
      @universe[{x: r.x, y: r.y}] += [r.name]
      @Y = (@Y + [r.y]).minmax
      @X = (@X + [r.x]).minmax
  
      # Print the map incrementally, if requested    
      unless not step
        break unless i < step
        print "\n#{1 + i}. #{r.name.to_s.ljust(7)} goes #{d.to_s.ljust(5)}"\
              "\t--moving from #{old_location} to #{r.location}"
        show if withmap
      end
    end
  end
  # Pretty prints a listing of the robots’ positions
  def positions
    for r in @robots do
      puts "#{r.name.to_s.ljust(7)} is at #{r.location}"
    end
  end
  # How many houses have at least n presents?
  def presents n
    @universe.values.map(&:length).filter {|x| x >= n}.length
  end
  # How many deliveries were performed?
  def total_deliveries
    @universe.values.map(&:length).sum
  end
end # class DistributionsCompany
