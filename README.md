# q422-governance-notifications


## Summary

Starting a notification system for contract events, namely governance proposals.

## Plan

1. Create beanstalkd instance
2. Publish raw contract events to it
3. Convert events to notification jobs
4. Run jobs and notify consumers


## Open Questions

* How to register for notifications?
    * Platform dependent?
        * Telegram bot interaction?


