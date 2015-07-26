module router.url;
import vibe.d;

URLRouter getURLRouter() {
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
	router.get("*", serveStaticFiles("public/"));
	return router;
}