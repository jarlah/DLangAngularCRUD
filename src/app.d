import vibe.d;
import router.url;
import api.combined;

shared static this()
{
	auto client = connectMongoDB("127.0.0.1");
	auto router = getURLRouter();
	registerRestInterface!IAPI(router, new API(client), "/api/");
	auto settings = new HTTPServerSettings;
	settings.port = 9000;
	listenHTTP(settings, router);
}