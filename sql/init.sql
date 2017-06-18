create table resources (id int auto_increment, body text, index(id));
create table users (id int auto_increment, name varchar(255) unique, password varchar(255), index(id));

-- admin:password
insert into users (name, password) values ("admin", "[SHA512]Bc5AXJwKWENxCElt4oXj67XAjABhM0CB7GbMOoxYjmg=$RLh0WaJrqwsCc+9pfYwjFFgDLUqPEJKGZnhTBWBs/Lg9o45PJVjzZEVEis4H3dWP1t6kEK6F2rK+hw56Y3yuNg==");

