# discourse-anonymous-categories

Always-anonymous categories for Discourse

## Why does this exist?

Discourse's anonymous posting functionality is great, but it's a global setting: your site either allows anonymous posting everywhere (except for security-restricted categories).  If you want a single—or just a few—categories that enforce always-anonymous posting, this plugin is for you.

## How does it work?

The discourse-anonymous-categories plugin adds a configuration setting for each category to **force** posts to be made anonymously.  _**All**_ posts to these categories—both new topics and replies—will automatically be performed as a user's anonymous pseudonym, regardless of the global anonymous-posting setting.

## Known Issues

If the category could not normally be posted in by an anonymous user, turning on the "force anonymous posting" setting will result in many unhappy users.  No attempt is made to detect whether an anonymous user (typically at trust level 1) will be able to post successfully; it simply fails with a "You are not permitted to view the requested resource" alert.

In order to trick the UI, the post is treated as a "queued" post.  Otherwise, the Discourse front-end doesn't see the anonymous post as the same as the one from the user, and thus doesn't clear out the post editor.  By returning a "this post is queued" result, the editor behaves a bit better.  Yes, this can be somewhat surprising.  On the other hand, it gives us a chance to inform the user that the post was made anonymously, which they might not otherwise expect.

"Liking" still isn't anonymous, so if you may want to look at the [discourse-feature-voting](https://github.com/joebuhlig/discourse-feature-voting) plugin as a companion to this one.
