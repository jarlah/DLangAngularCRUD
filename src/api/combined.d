module api.combined;
import vibe.d;
import model.contact;
import model.person;

interface IAPI
{
	// Person
	@path("person") @method(HTTPMethod.POST)
	PersonDoc[] addPerson(Person person);
	
	@path("person/:id") @method(HTTPMethod.PUT)
	void updatePerson(Person person, string _id);
	
	@path("person") @method(HTTPMethod.GET)
  	PersonDoc[] getPerson();
  	
	@path("person/:id") @method(HTTPMethod.GET)
	PersonDoc getPerson(string _id);
	
	@path("person/:id") @method(HTTPMethod.DELETE)
	void deletePerson(string _id);
	
	// Contact
	@path("contact") @method(HTTPMethod.POST)
	void addContact(Contact contact);
	
	@path("contact/:id") @method(HTTPMethod.PUT)
	void updateContact(Contact contact, string _id);
	
	@path("contact") @method(HTTPMethod.GET)
  	ContactDoc[] getContact();
  	 
	@path("contact/:id") @method(HTTPMethod.GET)
	ContactDoc getContact(string _id);
	
	@path("contact/:id") @method(HTTPMethod.DELETE)
	void deleteContact(string _id);
}


class API : IAPI
{
	this(MongoClient _client) {
		this.personColl = _client.getCollection("app.person");
		this.contactColl = _client.getCollection("app.contact");
	}
	
	private:
	MongoCollection personColl;
	MongoCollection contactColl;
	
	public:
	// Person
	PersonDoc[] addPerson(Person person) {
		personColl.insert(person);
		return getPerson();
	}
	
	void updatePerson(Person person, string _id) {
		auto query = Bson.emptyObject;
		query["$set"] = serializeToBson(person);
		personColl.update(["_id": Bson(BsonObjectID.fromString(_id))], query);
	}

	PersonDoc[] getPerson() {
		return personColl.find().map!(doc => deserialize!(BsonSerializer, PersonDoc)(doc)).array;
	}

	PersonDoc getPerson(string id) {
		return deserialize!(BsonSerializer, PersonDoc)(personColl.findOne(["_id":id]));
	}

	void deletePerson(string id) {
		personColl.remove(["_id": BsonObjectID.fromString(id)] );
	}
	
	// Contact
	void addContact(Contact contact) {
		contactColl.insert(contact);
	}
	
	void updateContact(Contact contact, string _id) {
		auto query = Bson.emptyObject;
		query["$set"] = serializeToBson(contact);
		contactColl.update(["_id": Bson(BsonObjectID.fromString(_id))], query);
	}

	ContactDoc[] getContact() {
		return contactColl.find().map!(doc => deserialize!(BsonSerializer, ContactDoc)(doc)).array;
	} 

	ContactDoc getContact(string id) {
		return deserialize!(BsonSerializer, ContactDoc)(contactColl.findOne(["_id":id]));
	}

	void deleteContact(string id) {
		contactColl.remove(["_id": BsonObjectID.fromString(id)] );
	}
}
