module model.person;
import vibe.d;

// used for json, so it cant/should contain bsonobjectid
class Person {
	ulong id;
	string firstName; 
	string lastName;
}

class PersonDoc : Person {
	BsonObjectID _id;
}