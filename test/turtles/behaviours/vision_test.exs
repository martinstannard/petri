defmodule Processor.Creatures.Behaviour.VisionTest do
  use ExUnit.Case, async: true

  alias Processor.Creatures.Behaviour.Vision

  @pi :math.pi()
  @twopi :math.pi() * 2.0
  @piontwo :math.pi() / 2.0
  @threepiontwo :math.pi() * 3.0 / 2.0

  describe "left eye not overlapping 0" do
    setup do
      %{
        eye_offset: 1.0,
        eye_width: 1.0
      }
    end

    test "for different bearings", state do
      assert(Vision.left_eye_sees(0.0, state) == false)
      assert(Vision.left_eye_sees(3.0, state) == false)
      assert(Vision.left_eye_sees(@twopi - 0.25, state) == false)
      assert(Vision.left_eye_sees(@twopi - 0.51, state) == true)
      assert(Vision.left_eye_sees(@twopi - 0.99, state) == true)
      assert(Vision.left_eye_sees(@twopi - 1.49, state) == true)
      assert(Vision.left_eye_sees(@twopi - 1.51, state) == false)
    end
  end

  describe "left eye overlapping 0" do
    setup do
      %{
        eye_offset: 0.5,
        eye_width: 2.0
      }
    end

    test "multiple bearings", state do
      assert(Vision.left_eye_sees(1.51, state) == false)
      assert(Vision.left_eye_sees(0.0, state) == true)
      assert(Vision.left_eye_sees(@twopi - 0.25, state) == true)
      assert(Vision.left_eye_sees(@twopi - 0.51, state) == true)
      assert(Vision.left_eye_sees(@twopi - 0.99, state) == true)
      assert(Vision.left_eye_sees(@twopi - 1.49, state) == true)
      assert(Vision.left_eye_sees(@twopi - 1.51, state) == false)
    end
  end

  describe "right eye not overlapping" do
    setup do
      %{
        eye_offset: 1.0,
        eye_width: 1.0
      }
    end

    test "multiple bearings", state do
      assert(Vision.right_eye_sees(0.0, state) == false)
      assert(Vision.right_eye_sees(3.0, state) == false)
      assert(Vision.right_eye_sees(0.25, state) == false)
      assert(Vision.right_eye_sees(0.51, state) == true)
      assert(Vision.right_eye_sees(0.99, state) == true)
      assert(Vision.right_eye_sees(1.49, state) == true)
      assert(Vision.right_eye_sees(1.51, state) == false)
    end
  end

  describe "right eye overlapping 0" do
    setup do
      %{
        eye_offset: 0.5,
        eye_width: 2.0
      }
    end

    test "multiple bearings", state do
      assert(Vision.right_eye_sees(@twopi - 0.51, state) == false)
      assert(Vision.right_eye_sees(@twopi - 0.25, state) == true)
      assert(Vision.right_eye_sees(0.0, state) == true)
      assert(Vision.right_eye_sees(0.51, state) == true)
      assert(Vision.right_eye_sees(0.99, state) == true)
      assert(Vision.right_eye_sees(1.49, state) == true)
      assert(Vision.right_eye_sees(1.51, state) == false)
      assert(Vision.right_eye_sees(1.51, state) == false)
    end
  end

  describe "turning" do
    test "with both eyes true returns 0" do
      assert(Vision.turn(true, true, 30.0) == 0.0)
    end

    test "with no eyes true returns angle" do
      assert(Vision.turn(false, false, 30.0) == 30.0)
    end

    test "with left eye true returns -angle" do
      assert(Vision.turn(true, false, 30.0) == -30.0)
    end

    test "with right eye true returns angle" do
      assert(Vision.turn(false, true, 30.0) == 30.0)
    end
  end

  describe "eye_sees" do
    test "is to the right of the right side" do
      assert(Vision.eye_sees(1.0, 2.0, 3.0) == false)
    end

    test "is to the left of the left side" do
      assert(Vision.eye_sees(1.0, 2.0, 0.1) == false)
    end

    test "is between the left and right sides" do
      assert(Vision.eye_sees(1.0, 2.0, 1.1) == true)
    end
  end

  describe "bearing" do
    setup do
      %{
        x: 100.0,
        y: 100.0,
        heading: 0.0
      }
    end

    test "heading 0", state do
      assert(Vision.bearing(100.0, -100.0, state) == 0.0)
      assert(Vision.bearing(100.0, 200.0, state) == @pi)
      assert(Vision.bearing(200.0, 100.0, state) == @threepiontwo)
      assert(Vision.bearing(-100.0, 100.0, state) == @piontwo)
    end

    test "heading pi", state do
      state = Map.put(state, :heading, @pi)
      assert(Vision.bearing(100.0, -100.0, state) == @pi)
      assert(Vision.bearing(100.0, 200.0, state) == 0.0)
      assert(Vision.bearing(200.0, 100.0, state) == @piontwo)
      assert(Vision.bearing(-100.0, 100.0, state) == @threepiontwo)
    end

    test "heading pi / 2.0", state do
      state = Map.put(state, :heading, @piontwo)
      assert(Vision.bearing(100.0, -100.0, state) == @piontwo)
      assert(Vision.bearing(100.0, 200.0, state) == @threepiontwo)
      assert(Vision.bearing(200.0, 100.0, state) == 0.0)
      assert(Vision.bearing(-100.0, 100.0, state) == @pi)
    end
  end
end
