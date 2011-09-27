require 'csv'

class Sketch < Processing::App
  load_libraries 'traer_physics_lib_src'
  import 'traer.physics'

  def pop_density_to_radius (pop_density)
    #potential alternative population density to circle radius algorithms...

    #(Math.log(pop_density) + 2)
    #Math.sqrt(pop_density)/4
    pop_density/10
  end

  def set_radii
    (0..@data.keys.size-1).each do |country_index|
      @balls[country_index].radius = pop_density_to_radius(@data[@data.keys[country_index]][@year].to_f)
    end
  end


  def setup

    size( 700, 750 )
    @box = [50, 50, 650, 650]
    frameRate( 24 )
    smooth
    ellipseMode( CENTER )
    noStroke

    font = createFont("Helvetica",15)
    textFont(font)

    @physics = ParticleSystem.new(0, 0.0 )
    @balls = []
    @data = {}
    @year = 0

    CSV.foreach( File.dirname(__FILE__) + '/data/population_data.csv' ) { |row| ['Country Name', 'Singapore', 'Monaco', 'Hong Kong SAR, China', 'Gibraltar', 'Macao SAR, China'].include?(row[1])  ? nil : @data[row[1]] = row[3..row.size-1] }

    @data.keys.each do |country|
      @balls << @physics.makeParticle( 1.0, random( @box[0], @box[2]), random( @box[1], @box[3]), 0 )
      @balls.last.radius = pop_density_to_radius(@data[country][@year].to_f)
    end
    
    @balls.each_index do |i|
      ball = @balls[i]

      ball.was_up_bounded = false
      ball.was_side_bounded = false

      ball.randomize(100)

      (i+1..@balls.size - 1).each do |othr_ball|
        pair = [ ball, @balls[othr_ball] ]
        @physics.makeAttraction(pair[0], pair[1], -50, 2)
      end
    end

  
  end
  
  
  def draw
    
    background 255 
    fill 255
    rect(@box[0], @box[1], @box[2] - @box[0], @box[3] - @box[1])

    @balls.each do |ball|
      handleBoundaryCollisions(ball, *@box)

      stroke 0 
      fill(255, 0) 
      ellipse( ball.position.x, ball.position.y, ball.radius*2, ball.radius*2 )
    end

    @physics.tick

    fill 0
    text(@year + 1961, 335, 705)
  end


  def handleBoundaryCollisions( p, min_x = 0, min_y = 0, max_x = width, max_y = height )

    p.up_bounded = false
    p.side_bounded = false
    p.position.set( constrain( p.position.x, min_x + p.radius, max_x - p.radius), constrain( p.position.y, min_y + p.radius, max_y - p.radius), 0 )

      if p.position.x <= min_x + p.radius
        !p.was_side_bounded ? p.velocity.set([-1.2*p.velocity.x, 3].max, p.velocity.y, 0 ) : nil
        p.side_bounded = true
      elsif p.position.x >= max_x - p.radius
        !p.was_side_bounded ? p.velocity.set([-0.7*p.velocity.x, -1.1].min, p.velocity.y, 0 ) : nil
        p.side_bounded = true
      end

      if p.position.y <= min_y + p.radius
        !p.was_up_bounded ? p.velocity.set( p.velocity.x, [-1.2*p.velocity.y, 3].max, 0 ) : nil
        p.up_bounded = true
      elsif p.position.y >= max_y - p.radius
        !p.was_up_bounded ? p.velocity.set( p.velocity.x, [-0.7*p.velocity.y, -1.1].min, 0 ) : nil
        p.up_bounded = true
      end

    p.was_up_bounded = p.up_bounded
    p.was_side_bounded = p.side_bounded

  end
  

  def keyPressed()
    if key == CODED
      if key_code == UP
        @year = (@year + 1) % 50
        set_radii
      elsif key_code == DOWN
        @year = (@year - 1) % 50
        set_radii
      end
    end
  end

end

class Java::TraerPhysics::Particle
  attr_accessor :radius, :up_bounded, :was_up_bounded, :side_bounded, :was_side_bounded

  def randomize(n)
    delta = ( rand(n - 1) - n/2.0 ) / 100.0
    velocity.add(delta, delta, 0)
  end

end

