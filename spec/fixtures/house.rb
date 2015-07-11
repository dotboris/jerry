# A door
class Door; end

# A window
class Window; end

# A house which has a door and a window
class House
  attr_reader :door, :window

  def initialize(door, window)
    @door = door
    @window = window
  end
end
