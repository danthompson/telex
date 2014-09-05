# 𝕋𝔼𝕃𝔼𝕏

[![Build Status](https://travis-ci.org/heroku/telex.svg)](https://travis-ci.org/heroku/telex)

![telex](docs/telex-cc-by-sa-jens-ohlig.jpg)

## setup
```
h addons:add hpg:s0
h pg:promote <that database>
h addons:add mailgun
h addons:add redisgreen
h config:add REDIS_PROVIDER=REDISGREEN_URL
h config:set API_KEY_HMAC_SECRET=$(dd if=/dev/urandom bs=127 count=1 2>/dev/null | openssl base64 -A)
h config:set HEROKU_API_KEY=<key>

git push heroku master
h run rake db:migrate
```
