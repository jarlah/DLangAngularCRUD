import vibe.d;
import std.stdio;
import std.algorithm;

shared static this()
{
	auto client = connectMongoDB("127.0.0.1");
	
	auto router = new URLRouter;
	router.get("/", (req, res)
	{
		res.render!("index.dt", req);
	});
	router.get("/reactjs", (req, res)
	{
		res.render!("reactjs.dt", req);
	});
	router.get("/flux", (req, res)
	{
		res.render!("flux.dt", req);
	});
	router.get("/angular", (req, res)
	{
		res.render!("angular.dt", req);
	});
	registerRestInterface!IAPI(router, new API(client), "/api/");
	router.get("*", serveStaticFiles("public/"));
	auto settings = new HTTPServerSettings;
	settings.port = 9000;
	listenHTTP(settings, router);
}

interface IAPI
{
	// Person
	@path("person") @method(HTTPMethod.POST)
	PersonDoc[] addPerson(PersonObj person);
	
	@path("person/:id") @method(HTTPMethod.PUT)
	void updatePerson(PersonObj person, string _id);
	
	@path("person") @method(HTTPMethod.GET)
  	PersonDoc[] getPerson();
  	
	@path("person/:id") @method(HTTPMethod.GET)
	PersonDoc getPerson(string _id);
	
	@path("person/:id") @method(HTTPMethod.DELETE)
	void deletePerson(string _id);
	
	// Contact
	@path("contact") @method(HTTPMethod.POST)
	void addContact(ContactObj contact);
	
	@path("contact/:id") @method(HTTPMethod.PUT)
	void updateContact(ContactObj contact, string _id);
	
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
	PersonDoc[] addPerson(PersonObj person) {
		personColl.insert(person);
		return getPerson();
	}
	
	void updatePerson(PersonObj person, string _id) {
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
	void addContact(ContactObj contact) {
		contactColl.insert(contact);
	}
	
	void updateContact(ContactObj contact, string _id) {
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

struct PersonObj {
	ulong id;
	string firstName; 
	string lastName;
}

struct PersonDoc {
	BsonObjectID _id;
	ulong id;
	string firstName;
	string lastName;
}

struct ContactObj {
	string name; 
	string phone;
	string email;
	string avatar;
}

struct ContactDoc {
	BsonObjectID _id;
	string name;
	string phone;
	string email;
	string avatar;
} 