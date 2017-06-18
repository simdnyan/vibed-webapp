module app;

import vibe.d;
import mysql;
import dyaml;
import resource;
import home;


void main()
{
    string address = "0.0.0.0";
    ushort port    = 8080;
    string configFile = "./vibed-webapp.yaml";

    readOption("bindAddress|b", &address, "Sets the address for listning.");
    readOption("port|p", &port, "Sets the port for listning.");
    readOption("config|c", &configFile, "Sets the config file path.");

    if (!finalizeCommandLineOptions())
      return;
    lowerPrivileges();

    auto config = Loader(configFile).load();
    auto dbConfig = config["mysql"];
    auto mysql = new MySQLPool(
        dbConfig["host"].as!string,
        dbConfig["user"].as!string,
        dbConfig["password"].as!string,
        dbConfig["database"].as!string,
        dbConfig["port"].as!ushort
    );
    Resource.mysql = mysql;

    auto settings = new HTTPServerSettings;
    settings.port = port;
    settings.bindAddresses = [address];

    auto router = new URLRouter;
    auto mysqlResource = new MySQLResourceImplementation;
    router.registerRestInterface(mysqlResource);

    router.registerWebInterface(new HomeConroller(mysql));

    router.post("/api/resources", &mysqlResource.postResources);
    router.put("/api/resources/:id", &mysqlResource.putResources);

    auto redisConfig = config["redis"];
    settings.sessionStore = new RedisSessionStore(
        redisConfig["host"].as!string,
        redisConfig["database"].as!long,
        redisConfig["port"].as!ushort
    );

    listenHTTP(settings, router);

    runEventLoop();
}

