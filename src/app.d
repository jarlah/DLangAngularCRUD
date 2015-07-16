import vibe.d;
import std.stdio;
import std.algorithm;

MongoClient client;

void index(HTTPServerRequest req, HTTPServerResponse res)
{
	res.render!("index.dt", req);
}

shared static this()
{
	client = connectMongoDB("127.0.0.1");
	auto router = new URLRouter;
	router.get("/", &index);
	registerRestInterface!IMyAPI(router, new API(), "/api/");
	auto settings = new HTTPServerSettings;
	settings.port = 9000;
	listenHTTP(settings, router);
}

interface IMyAPI
{
	@path("resource") @method(HTTPMethod.POST)
	Resource addResource(Resource resource);
	
	@path("resource") @method(HTTPMethod.GET)
  	Resource[] getResource();
  	
	@path("resource/:id") @method(HTTPMethod.GET)
	Resource getResource(int _id);
	
	@path("resource/:id") @method(HTTPMethod.DELETE)
	void deleteResource(int _id);
}


class API : IMyAPI
{
	private Resource[] _resources;

	Resource addResource(Resource resource) {
		auto coll = client.getCollection("app.resource");
		coll.insert(resource);
		return resource;
	}

	Resource[] getResource() {
		auto coll = client.getCollection("app.resource");
		return array(coll.find().map!(doc => deserialize!(BsonSerializer, Resource)(doc)));
	}

	Resource getResource(int id) {
		auto coll = client.getCollection("app.resource");
		auto doc = coll.findOne(["id":id]);
		return deserialize!(BsonSerializer, Resource)(doc);
	}

	void deleteResource(int id) {
		auto coll = client.getCollection("app.resource");
		coll.remove(["id": id] );
	}
}

struct Resource {
	ulong id;
	string firstName;
	string lastName;
}