import 'package:flutter_test/flutter_test.dart';
import 'friends_utils.dart';

void main() {
  test('FriendUser.fromJson parses JSON correctly', () {
    /*
    This tests that FriendUser.fromJson reads a JSON map correctly.
    THat the id is converted to an int.
    And that the username string is stored properly in the object.
    */

    // Examplea data for JSON  test
    final json = {
      'id': 66,
      'username': 'john',
    }; //create mock json obj

    final friend = FriendUser.fromJson(json); //Convert JSON to Dart object

    expect(friend.id, 66); //check object fields
    expect(friend.username, 'john');
  });

  test('FriendUser.fromJson converts numeric id correctly', () {
    final json = {
      'id': 3.0, // from JSON, could be double
      'username': 'bob',
    };

    final friend = FriendUser.fromJson(json);

    expect(friend.id, 3);
    expect(friend.username, 'bob');
  });
}
