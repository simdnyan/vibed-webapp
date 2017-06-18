module home;

import vibe.d;
import vibe.utils.validation;
import vibe.web.auth;
import mysql;
import dauth;
import dyaml;
import user;


@requiresAuth
class HomeConroller {

    MySQLPool mysql;

    this(MySQLPool mysql)
    {
        this.mysql = mysql;
    }

    @noRoute
    User authenticate(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        if (!req.session || !req.session.isKeySet("auth"))
            throw new HTTPStatusException(HTTPStatus.forbidden, "Not authorized to perform this action!");

        return req.session.get!User("auth");
    }

    @noAuth
    {
        @path("/")
        void getHome(scope HTTPServerRequest req, scope  HTTPServerResponse res)
        {
            import std.typecons : Nullable;

            Nullable!User auth;
            if (req.session && req.session.isKeySet("auth"))
                auth = req.session.get!User("auth");

            render!("home.dt", auth);
        }

        @path("/signup")
        {
            void getSignup(string _error = null)
            {
                string error = _error;
                render!("signup.dt", error);
            }

            @errorDisplay!getSignup
            void postSignup(ValidUsername userName, ValidPassword password, scope HTTPServerRequest req, scope HTTPServerResponse res)
            {
                enforce(!(req.session && req.session.isKeySet("auth")), "Already logged in.");

                char[] strArr = password.dup;
                Password pass = toPassword(strArr);
                string password_hash = makeHash(pass).toString();

                auto conn = mysql.lockConnection();
                Prepared insert = prepare(conn, "insert into `users` (`name`, `password`) values (?, ?)");
                insert.setArgs(to!string(userName), password_hash);
                auto rowsAffected = insert.exec();
                enforce(rowsAffected == 1, "Invalid password.");

                User u = {userName: userName};
                req.session = res.startSession;
                req.session.set("auth", u);

                redirect("./");
            }
        }

        void getLogin(string _error = null)
        {
            string error = _error;
            render!("login.dt", error);
        }

        @errorDisplay!getLogin
        void postLogin(ValidUsername userName, ValidPassword password, scope HTTPServerRequest req, scope HTTPServerResponse res)
        {
            enforce(!(req.session && req.session.isKeySet("auth")), "Already logged in.");

            auto conn = mysql.lockConnection();
            Prepared select = prepare(conn, "select * from `users` where `name`=?");
            select.setArgs(to!string(userName));
            ResultRange range = select.query();
            enforce(!range.empty, "Invalid password.");
            Row row = range.front;
            auto userPassword = to!string(row[2]);

            char[] strArr = password.dup;
            Password pass = toPassword(strArr);
            enforce(isSameHash(pass, parseHash(userPassword)), "Invalid password.");

            User u = {userName: userName};
            req.session = res.startSession;
            req.session.set("auth", u);
            redirect("./");
        }
    }

    @anyAuth
    {
        void postLogout()
        {
            terminateSession();
            redirect("./");
        }
    }
 }