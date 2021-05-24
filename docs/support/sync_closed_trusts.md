# Sync closed trusts from GIAS

Previously only open trusts were updated so any trusts closed would remain open in our system.

This has now been updated so any GIAS closed trusts are automatically closed if they don't contain any schools in our system.

However previous to this automation we need to retroactively close trusts before the last time they updated.

## Retroactively sync closed trusts in Rails console

By calling the private function `close_trusts` and using a very old date we can sync it up.

Any trusts that are skipped will be raised to Sentry with a list of failed trust ids that couldn't be closed for manualy investigation.

```ruby
TrustUpdateService.new.send(:close_trusts, 5.years.ago)
```
