# Shorty: A Simple, Self-Hosted URL Shortener

[![GoDoc](https://godoc.org/github.com/Clever/shorty?status.svg)](http://godoc.org/github.com/Clever/shorty)

What, you need more information than the title?

I looked around and found a bunch of toy examples of backend URL shorteners in Go, or PHP/MySQL solutions which seemed complicated and less-than-fully-featured.
I wanted to make something that spins up with super-simple configuration and has a pluggable backend. Please contribute!

If you don't like what you see, you can also check out the other alternatives:
- [YOURLS](yourls.org)
- [Google Apps](http://www.makeuseof.com/tag/use-your-google-apps-domain-to-make-short-urls/)
- [Other "shorty" repos on Github](https://github.com/search?q=shorty)

## Goals For The Project
- Optimized for simple deployment
- Designed for internal network use
- Clear ownership of URLs
- Expiry of URLs unless explicitly set (TODO: flash warning if URL is about to expire)
- Tags to allow grouping / organization

## Deployment
After a few simple steps, I promise you will be up and running and won't need to touch it again.

### Pick a backend database.
Currently the only two options are:
- PostgreSQL
- Redis

*If you have a favorite backend you don't see here, please help me by creating a pull request!*
I recommend a persistent storage - your users are not going to be happy if they lose these URLs!

### Edit the database creation script
Find the script corresponding to your database and open it in a text editor. If there are TODOs, follow the instructions.
You may modify this as you wish (for instance, perhaps you may want to use a different Postgres `schema` than '`shortener`'), however this means that you'll likely have to be more careful setting other environment variables later.
- [PostgreSQL](https://github.com/schimmy/shorty/blob/master/pg_schema.sql)

### Run the database creation script

#### PostgreSQL
Enter your admin-user's password when prompted.
```bash
psql -p 5432 -U YOUR_ADMIN_USER -d YOUR_DATABASE -f ./scripts/postgres.sql
```
You also might want to change the default password for the `shortener` user:
```bash
psql -p 5432 -U YOUR_ADMIN_USER -d YOUR_DATABASE -c "ALTER ROLE shortener WITH PASSWORD 'TODO'"
```

### Pick a deployment method

#### Docker
The latest published image at: [schimmy/easy-url-shortener](dockerhub TODO). Run this Docker container with the relevant environment variables for your database.

#### Standalone Server (Windows, Linux)
We also release binaries for Windows and Linux, available at [github.com/schimmy/shorty/releases](https://github.com/schimmy/shorty/releases).
After setting the relevant environment variables, simply execute the binary.
Likely you'll want to ensure that it restarts on reboot, etc, and I've included an [init script](TODO) to help you out.

Linux example:
```bash
PG_HOST=my-postgres.colinschimmelfing.com PG_PASS=super_secret ./shorty --read-only=false
```

## That's it, you're done!

If you'd like other methods of deploying, please create a pull request with support and documentation.

### Advanced Usage

#### Readonly / External Facing

You might want to expose and use these redirects outside of your VPN, but there's a problem: you need to ensure that *your organization* has control over the URLs. While we will add an authentication gateway in the future, you can also use the `read-only` mode to solve this issue.

To do this, run one instance in `read-only` mode, and point your external DNS (in this example: `colinshorty.com`) at that instance:
```bash
PG_HOST=my-postgres.colinschimmelfing.com PG_PASS=super_secret ./shorty --read-only=true --domain=colinshorty.com --protocol=https
```
Then, run one private instance pointing to the same backend. This is your admin interface.
Set all parameters except `read-only` to the same values as the external instance so that it's easier to copy-paste the submitted URLs
```bash
PG_HOST=my-postgres.colinschimmelfing.com PG_PASS=super_secret ./shorty --read-only=false --domain=colinshorty.com --protocol=https
```

