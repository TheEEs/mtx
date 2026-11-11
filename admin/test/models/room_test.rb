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

  test "scopes filter public and private rooms" do
    assert_includes Room.public_rooms, rooms(:one)
    assert_not_includes Room.public_rooms, rooms(:private_room)

    assert_includes Room.private_rooms, rooms(:private_room)
    assert_not_includes Room.private_rooms, rooms(:one)
  end

  test "private room does not require password, but can have optional password" do
    room = Room.new(
      name: "Private No Pass",
      owner: "Tester",
      description: "Description",
      valid_from: 1.day.ago,
      valid_to: 1.day.from_now,
      is_public: false
    )
    assert room.valid?
    assert_nil room.password_digest
    assert_not room.password_protected?

    room.password = "secret123"
    assert room.valid?
    assert room.password_protected?
    assert room.authenticate("secret123")
    assert_not room.authenticate("wrongpass")
  end

  test "public room clears password_digest" do
    room = Room.new(
      name: "Public Pass",
      owner: "Tester",
      description: "Description",
      valid_from: 1.day.ago,
      valid_to: 1.day.from_now,
      is_public: true,
      password: "secret123"
    )
    assert room.valid?
    assert_nil room.password_digest
    assert_not room.password_protected?
  end
end
