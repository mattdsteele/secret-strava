# secret-strava

Strava doesn't have a great way to customize the visibilty of your activities, and it's gotten worse over time.

This tool attempts to take back some of that control, using a webhook to update the visibility.

## ⚠ 🚨 😱

This probably won't work for anyone other than me, because while Strava has an API, it doesn't actually let you change an activity's visibility.

To get around this I had to screen-scrape using Mechanize; which requires an actual userid/password instead of OAuth.

If you actually want to use this, open a ticket and I'll put some docs together on how you can self-host. 
