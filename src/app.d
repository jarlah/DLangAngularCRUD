import vibe.d;
import std.stdio;
import std.algorithm;

MongoClient client;

shared static this()
{
	client = connectMongoDB("127.0.0.1");
	auto router = new URLRouter;
	router.get("/", (req, res)
	{
		res.render!("index.dt", req);
	});
	registerRestInterface!IMyAPI(router, new API(), "/api/");
	auto settings = new HTTPServerSettings;
	settings.port = 9000;
	listenHTTP(settings, router);
}

interface IMyAPI
{
	@path("person") @method(HTTPMethod.POST)
	Person addPerson(Person person);
	
	@path("person") @method(HTTPMethod.GET)
  	Person[] getPerson();
  	
	@path("person/:id") @method(HTTPMethod.GET)
	Person getPerson(int _id);
	
	@path("person/:id") @method(HTTPMethod.DELETE)
	void deletePerson(int _id);
}


class API : IMyAPI
{
	private:
	const string COLL = "app.person";
	
	public:
	Person addPerson(Person person) {
		auto coll = client.getCollection(COLL);
		coll.insert(person);
		return person;
	}

	Person[] getPerson() {
		auto coll = client.getCollection(COLL);
		return coll.find().map!(doc => deserialize!(BsonSerializer, Person)(doc)).array;
	}

	Person getPerson(int id) {
		auto coll = client.getCollection(COLL);
		auto doc = coll.findOne(["id":id]);
		return deserialize!(BsonSerializer, Person)(doc);
	}

	void deletePerson(int id) {
		auto coll = client.getCollection(COLL);
		coll.remove(["id": id] );
	}
}

struct Person {
	ulong id;
	string firstName;
	string lastName;
}