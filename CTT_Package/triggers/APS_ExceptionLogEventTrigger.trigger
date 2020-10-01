/**
  * @author        Parasuram Basi
  * @date          02nd-Oct 2018
  * @description   This is the Trigger which calls APS_UTIL_LoggingService_Updated class for creating Exception Log Object records.
  */
trigger APS_ExceptionLogEventTrigger on APS_ExceptionLog__e(after insert) {                                                    
     APS_LoggingService.logHandledException(Trigger.New);
}