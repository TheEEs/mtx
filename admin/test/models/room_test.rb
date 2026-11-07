require "test_helper"

class RoomTest < ActiveSupport::TestCase
  test "expired? returns true when current time is past valid_to" do
    room = Room.new(
      name: "Expired Room",
      owner: "Tester",
      description: "Description",
      valid_from: 2.days.ago,
      valid_to: 1.day.ago
    )
    assert room.expired?
    assert_not room.available?
  end

  test "expired? returns false when current time is before valid_to" do
    room = Room.new(
      name: "Active Room",
      owner: "Tester",
      description: "Description",
      valid_from: 1.day.ago,
      valid_to: 1.day.from_now
    )
    assert_not room.expired?
    assert room.available?
  end

  test "not_started? returns true when current time is before valid_from" do
    room = Room.new(
      name: "Future Room",
      owner: "Tester",
      description: "Description",
      valid_from: 1.day.from_now,
      valid_to: 2.days.from_now
    )
    assert room.not_started?
    assert_not room.available?
  end
end
