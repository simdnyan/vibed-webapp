module resource;

import vibe.d;
import mysql;

class Resource
{
    static MySQLPool mysql;
    static struct model{
        long id;
        string body_;
    }

    static model get(string id)
    {
        auto conn = mysql.lockConnection();
        Prepared select = prepare(conn, "select * from `resources` where `id`=?");
        select.setArgs(id);
        ResultRange range = select.query();
        enforceHTTP(!range.empty, HTTPStatus.notFound, httpStatusText(HTTPStatus.notFound));
        Row row = range.front;

        auto result = model();
        row.toStruct(result);
        return result;
    }

    static model create(Json json)
    {
        string body_ = json["body"].get!(string);

        auto conn = mysql.lockConnection();
        Prepared insert = prepare(conn, "insert into `resources` (`body`) values (?)");
        insert.setArgs(body_);
        auto rowsAffected = insert.exec();

        ResultRange range = query(conn, "select * from `resources` where `id`=last_insert_id()");
        Row row = range.front;

        auto result = model();
        row.toStruct(result);
        return result;
    }

    static model update(string id, Json json)
    {
        string body_ = json["body"].get!(string);

        auto conn = mysql.lockConnection();
        Prepared update = prepare(conn, "update `resources` set body=? where id=?");
        update.setArgs(body_,id);
        auto rowsAffected = update.exec();

        Prepared select = prepare(conn, "select * from `resources` where `id`=?");
        select.setArgs(id);
        ResultRange range = select.query();
        Row row = range.front;

        auto result = model();
        row.toStruct(result);
        return result;
    }

    static void remove(string id)
    {
        auto conn = mysql.lockConnection();
        Prepared select = prepare(conn, "delete from `resources` where `id`=?");
        select.setArgs(id);
        auto rowsAffected = select.exec();
    }
}

interface MySQLResourceAPI
{
    @path("resources/:id"){
        Resource.model getResource(string _id);
        void deleteResource(string _id);
    }
}

class MySQLResourceImplementation : MySQLResourceAPI
{
    Resource.model getResource(string _id)
    {
        return Resource.get(_id);
    }

    void postResources(HTTPServerRequest req, HTTPServerResponse res)
    {
        auto resource = Resource.create(req.json);
        res.writeJsonBody(serializeToJson(resource), HTTPStatus.created);
    }

    void putResources(HTTPServerRequest req, HTTPServerResponse res)
    {
        auto _id = req.params["id"];
        auto resource = Resource.update(_id, req.json);
        res.writeJsonBody(serializeToJson(resource), HTTPStatus.ok);
    }

    void deleteResource(string _id)
    {
        Resource.remove(_id);
    }
}
