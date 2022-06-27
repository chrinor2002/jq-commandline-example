#!/bin/bash

docker compose up -d

# https://stackoverflow.com/questions/2153882/how-can-i-shuffle-the-lines-of-a-text-file-on-the-unix-command-line-or-in-a-shel
shuf() { awk 'BEGIN {srand(); OFMT="%.17f"} {print rand(), $0}' "$@" | sort -k1,1n | cut -d ' ' -f2-; }

read -r -d '' Q << EOF
SELECT JSON_OBJECT(
  'uuid', uuid,
  'title', title, 
  'article', article
) as json FROM articles;
EOF

# Given the preconfigured database
# When we SELECT all the rows as JSON_OBJECTs
JSON_ROWS=$(echo "$Q" | docker compose exec --no-TTY db mysql -h 127.0.0.1 -u root -proot -D example | tail +2)

# Then we get all the rows... as expected
echo "$JSON_ROWS"

echo "^ Raw Json rows from database"
echo ""
echo "About to simulate fetching these rows from a random api, and dumping to multiple json files..."
printf "Press any key to continue" && read -n 1 line && printf "\n"

# Given a clean temporary location
rm -rf ./tmp
mkdir ./tmp
# When we...
for i in {0..9}
do
  f="./tmp/cache_response_${i}.json"
  # shuffle the 1000 rows, and take the first 10, and format using jq into a file
  echo "$JSON_ROWS" | shuf | head -n 100 | docker run -i stedolan/jq -s '' > $f
done
# Then the result is a simulation of some kind of fetch returning 10 files containing json chunks (paginated results)

echo "Here are the files created for the simulation:"
ls -la ./tmp
