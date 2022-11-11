# q422-governance-notifications


## Summary

Starting a notification system for contract events, namely governance proposals.

## Components

### Notification Platform

* Data Source (blockscout rc1staging instance)
* Message Queue (beanstalkd)
* Processor
    * Filter events, convert to notification jobs 
* Notifier
    * Execute notification jobs

### Platform consumers

* Telegram
    * Host bot on telegram 
    * Manage telegram user subscriptions and notifications
* Request bin
    * Log requests to console

## Todo

* Implement platform subscriptions + notifications

### Completed

* Implement metrics
* Create beanstalkd instance
* Publish raw contract events to it
* Convert events to notification jobs (basic)
* Setup infrastructure
* Create placeholder components
* Implement notifier
* Implement processor
* Implement telegram bot


