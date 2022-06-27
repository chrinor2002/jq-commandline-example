#!/bin/bash

docker compose up -d

ALL_UUIDS_QUERY="SELECT uuid FROM articles;"

# Given the preconfigured database
# When we SELECT all UUIDs as a list
echo "$ALL_UUIDS_QUERY" | docker compose exec --no-TTY db mysql -h 127.0.0.1 -u root -proot -D example | tail +2 | tee db_ids
# Then we get all the uuids
# Note: tail +2 is like saying, give me the all the last of the file, starting at +2, but that means 1 line past the end, loop back to the start, and plus one more.

echo "Got all uuids from database."
printf "Press any key to continue" && read -n 1 line && printf "\n"

# Given the a bunch of fetched cached data in json files
# When we combine them using jq
# https://stedolan.github.io/jq/manual/
cat tmp/cache_response_*.json | docker run -i stedolan/jq -s '[.[][]]' > tmp/all.json
# @recomend: learn how to leverage glob https://tldp.org/LDP/abs/html/globbingref.html
# Then the result is a full arrayed dataset in a single file
ls -la tmp

echo "Combined ids from responses into single all.json file."
printf "Press any key to continue" && read -n 1 line && printf "\n"

# Given the "all" file
# When we need to determine just the ids from the payloads
# Then we get the list of only the ids from the cached responses
cat tmp/all.json | docker run -i stedolan/jq -r '.[] | .uuid' | tee cached_ids

echo "Got full list of cache ids."
printf "Press any key to continue" && read -n 1 line && printf "\n"

# Given the objective: Determine the ids that are in the database, but not in the cache
# When we find out the ids in the DB
# https://unix.stackexchange.com/questions/158234/tool-in-unix-to-subtract-text-files
ONLY_IN_DB=$(cat db_ids | grep -vxFf cached_ids > only_in_db)
ONLY_IN_CACHE=$(cat cached_ids | grep -vxFf db_ids > only_in_cache)
# INTERSECTION=$(cat db_ids | grep -xFf cached_ids | tee intersection) # This is here as an example
# Then we see, nothing is only in the cache

echo ""

echo "db_ids size"
cat db_ids | wc -l

echo "cached_ids size"
cat cached_ids | wc -l

echo "unique cached ids (simulated cached overlap where the same id was returned on multiple pages)"
cat cached_ids | sort | uniq | wc -l

echo "ONLY_IN_DB"
cat only_in_db | wc -l
echo "use \`cat only_in_db\` to see contents"
echo ""

echo "ONLY_IN_CACHE"
cat only_in_cache | wc -l
echo "use \`cat only_in_cache\` to see contents"
echo ""
