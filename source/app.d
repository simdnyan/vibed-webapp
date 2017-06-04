import vibe.d;
import mysql;
import dyaml;
import resource;

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

    auto settings = new HTTPServerSettings;
    settings.port = port;
    settings.bindAddresses = [address];

    auto router = new URLRouter;
    auto mysqlResource = new MySQLResourceImplementation;
    router.registerRestInterface(mysqlResource);
    router.post("/resources", &mysqlResource.postResources);
    router.put("/resources/:id", &mysqlResource.putResources);

    auto dbConfig = config["database"];
    auto mysql = new MySQLPool(
        dbConfig["host"].as!string,
        dbConfig["user"].as!string,
        dbConfig["password"].as!string,
        dbConfig["database"].as!string,
        dbConfig["port"].as!ushort
    );
    Resource.mysql = mysql;

    listenHTTP(settings, router);

    runEventLoop();
}

