vibed-webapp
============

vibe.d Web Application sample

# Usage

## Run

```
$ docker-compose up
```

## Send requests

```
$ curl localhost:8080/api/resources/1
{"statusMessage":"Not Found"}

# create
$ curl -X POST -H "Content-type: application/json" -d '{"body": "abc123"}' localhost:8080/api/resources
{"body":"abc123","id":1}

# read
$ curl localhost:8080/api/resources/1
{
	"id": 1,
	"body": "abc123"
}

# update
$ curl -X PUT -H "Content-type: application/json" -d '{"body": "xyz789"}' localhost:8080/api/resources/1
{"body":"xyz789","id":1}

# delete
$ curl -X DELETE localhost:8080/api/resources/1
$ curl localhost:8080/api/resources/1
{"statusMessage":"Not Found"}
```
