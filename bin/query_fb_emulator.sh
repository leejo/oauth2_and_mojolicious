#!/bin/bash

token=$1

curl -k -v -XGET -H"Authorization: Bearer $token" 'https://127.0.0.1:3000/me' | json_pp
