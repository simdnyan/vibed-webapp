module user;

import vibe.d;

struct User {
    ulong id;
    string userName;
    @ignore string password;
}

