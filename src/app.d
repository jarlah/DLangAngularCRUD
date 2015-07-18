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
	
	registerRestInterface!IAPI(router, new API(client), "/api/");
	
	auto settings = new HTTPServerSettings;
	settings.port = 9000;
	
	listenHTTP(settings, router);
}

interface IAPI
{
	@path("person") @method(HTTPMethod.POST)
	void addPerson(PersonObj person);
	
	@path("person/:id") @method(HTTPMethod.PUT)
	void updatePerson(PersonObj person, string _id);
	
	@path("person") @method(HTTPMethod.GET)
  	PersonDoc[] getPerson();
  	
	@path("person/:id") @method(HTTPMethod.GET)
	PersonDoc getPerson(string _id);
	
	@path("person/:id") @method(HTTPMethod.DELETE)
	void deletePerson(string _id);
}


class API : IAPI
{
	this(MongoClient _client) {
		this.coll = _client.getCollection("app.person");
	}
	
	private:
	MongoCollection coll;
	
	public:
	void addPerson(PersonObj person) {
		coll.insert(person);
	}
	
	void updatePerson(PersonObj person, string _id) {
		auto query = Bson.emptyObject;
		query["$set"] = serializeToBson(person);
		coll.update(["_id": Bson(BsonObjectID.fromString(_id))], query);
	}

	PersonDoc[] getPerson() {
		return coll.find().map!(doc => deserialize!(BsonSerializer, PersonDoc)(doc)).array;
	}

	PersonDoc getPerson(string id) {
		return deserialize!(BsonSerializer, PersonDoc)(coll.findOne(["_id":id]));
	}

	void deletePerson(string id) {
		coll.remove(["_id": BsonObjectID.fromString(id)] );
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