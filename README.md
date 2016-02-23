# discourse-anonymous-categories

Always-anonymous categories for Discourse

## Why does this exist?

Discourse's anonymous posting functionality is great, but it's a global setting: your site either allows anonymous posting everywhere (except for security-restricted categories).  If you want a single—or just a few—categories that enforce always-anonymous posting, this plugin is for you.

## How does it work?

The discourse-anonymous-categories plugin adds an admin configuration setting (`anonymous_categories`) that lets you specify exactly which categories should be treated as "always anonymous".  Posts to these categories—both new topics and replies—will automatically be performed as a user's anonymous pseudonym, regardless of the global anonymous-posting setting.


## TO-DO

* "like" as anonymous user, or mask likes if done as normal user
