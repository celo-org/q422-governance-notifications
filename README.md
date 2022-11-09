# q422-governance-notifications


## Summary

Starting a notification system for contract events, namely governance proposals.


## Components

* Data Source (blockscout rc1staging instance)
* Message Queue (beanstalkd)
    * + UI pod
* Processor
    * Filter events, convert to notification jobs 
* Notifier
    * Execute notification jobs

## Todo

* Implement notifier
* Implement processor
* Implement telegram bot

### Completed

* Create beanstalkd instance
* Publish raw contract events to it
* Convert events to notification jobs (basic)
* Setup infrastructure
* Create placeholder components


