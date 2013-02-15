myg is a replacement for iGoogle

It is a sinatra application

provide your exported iGoogle preferences and this will parse it to get set up.  You can export your settings from http://www.google.com/ig/settings at the bottom of the page.

Still in early development.

Todo list:
* Pick a storage engine so we don't have to parse XML all the time
---> Redis 
* Pick a storage engine to use to cache fetched RSS/ATOM content
--->
* Pick a front end framework for the frontend -- maybe foundation? This should work on mobile and desktop browsers
---> Foundation
* authentication
---> 

* once the initial prefs are loaded and stored, provide a way to edit/manage which feeds on which pages

--------
# Data Structure

User Preference
--
prefernce files are expected to be your exported iGoogle settings xml file.
The primary store for this is the xml file and we parse it frequently.

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


Fetched Tab Cache
--
This is stored as JSON in redis. This represents the fetched RSS for a whole
Tab's content.  The key is a username (still just hardcoded for now) and the
tab title, so "kolber-Tech" or what have you.
```
{
    'feed_title' : "NY Times",
    'title'      : "Dewey Beats Truman",
    'url'        : "http://nytimes.com/dbt.html",
    'summary'    : "Lorum ipsum dolor sit amet"
}
```


