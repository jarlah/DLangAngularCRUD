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
	void addPerson(Person person);
	
	@path("person") @method(HTTPMethod.GET)
  	Person[] getPerson();
  	
	@path("person/:id") @method(HTTPMethod.GET)
	Person getPerson(int _id);
	
	@path("person/:id") @method(HTTPMethod.DELETE)
	void deletePerson(int _id);
}


class API : IAPI
{
	this(MongoClient _client) {
		this.coll = _client.getCollection("app.person");
	}
	
	private:
	MongoCollection coll;
	
	public:
	void addPerson(Person person) {
		coll.insert(person);
	}

	Person[] getPerson() {
		return coll.find().map!(doc => deserialize!(BsonSerializer, Person)(doc)).array;
	}

	Person getPerson(int id) {
		return deserialize!(BsonSerializer, Person)(coll.findOne(["id":id]));
	}

	void deletePerson(int id) {
		coll.remove(["id": id] );
	}
}

struct Person {
	ulong id;
	string firstName;
	string lastName;
}