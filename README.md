FeedMe
---

Originally named "myg and later change to "feedme", this is a replacement for iGoogle - in other words, it is an RSS Aggregator and reader.

It is a Sinatra application.

You can provide your exported iGoogle preferences and this will parse it to get set up.  You can export your settings from http://www.google.com/ig/settings at the bottom of the page.

# Status

Still in development, but stable enough for me to use to browse my feeds.  This code has served as a device for me to learn more about
Ruby.

Todo list:
* Pick a storage engine so we don't have to parse XML all the time
---> Redis for short term caching
* Pick a storage engine to use to cache fetched RSS/ATOM content
--->
* Pick a front end framework for the frontend -- maybe foundation? This should work on mobile and desktop browsers
---> Foundation (tried this first, didn't hate or love it)
---> EmberJS (the current focus, at /e/)
* authentication
---> punting for now
* once the initial prefs are loaded and stored, provide a way to edit/manage which feeds on which pages

--------
# Data Flows

## User Configs

- Feeds are grouped together in something called a "tab".
- A User can have one or more tabs.
- Feeds can be active or inactive.

## Fetching Feeds

- Read the user's preferences and know which tab or tabls we care about.
- Fetch and parse the feed.
    - Each feed is broken down into articles that are persisted to the backend - mysql so far.
    - Each feed is also converted to json appropriate for populating the EmberJS frontent and stored in redis.


# Data Structures

## User Preference
--
Preference files are expected to be your exported iGoogle settings xml file.
This is initially read (once) from file and stored into and subsequently is read
from a backend storage - so far just MySQL.

This specifies:
```
<Tab title="Tech">
    <Section>
        <Module type=RSS>
            <UserPref numItems=9>
            <ModulePref xmlUrl="http://feed.net/feed.xml">
        </Module>
   </Section> 
</Tab>
```

## Tab Data Cache

This is stored as JSON in redis. This represents the fetched RSS for a whole
Tab's content.  The key is a username (still just hardcoded for now) and the
tab title, so "kolber-Tech" or what have you, where "kolber" indicates the user
and "Tech" indicates which of that users tabs.
```
{
    'feed_title' : "NY Times",
    'title'      : "Dewey Beats Truman",
    'url'        : "http://nytimes.com/dbt.html",
    'summary'    : "Lorum ipsum dolor sit amet"
}
```


