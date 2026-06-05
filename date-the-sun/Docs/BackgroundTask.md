# BackgroundTask

Some adjustment needed for Background Task, such as renaming identifier for:
- `Permitted background task scheduler identifiers`: `<xxx>.date-the-sun.schedule-sunset-sunrise` 

## On Debugging
Set breakpoint after submitting the task, then run this in `lldb` terminal.

```shell
e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"dev.heryan.date-the-sun.schedule-sunset-sunrise"]
```
