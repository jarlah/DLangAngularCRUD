module model.contact;
import vibe.d;

// used for json, so it cant/should contain bsonobjectid
class Contact {
	string name; 
	string phone;
	string email;
	string avatar;
}

class ContactDoc : Contact {
	BsonObjectID _id;
}