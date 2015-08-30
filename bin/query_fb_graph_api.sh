#!/bin/bash

token=$1

curl -XGET "https://graph.facebook.com/me?access_token=$token" | json_pp
