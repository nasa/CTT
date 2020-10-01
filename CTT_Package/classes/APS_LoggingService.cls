/**
  * @author        Parasuram Basi
  * @date          05-Oct-2018
  * @description   UTIL class for the purpose of logging handled and unhandled exceptions in the form of ExceptionLog__c record.
  */
public without sharing class APS_LoggingService{ 
      
    /**
      * @description       This method is called in case the User obtains a handled Exception. This method in turn calls methods to build and insert ExceptionLog__c records. It also checks if the record can be merged with a pre-existing record.
      * @param             excp the Exception object
      * @param             orgID the organization ID
      * @param             appName the Application Name
      * @param             className the Class Name
      * @param             methodName the Method Name
      * @param             triggerName the Trigger Name
      * @param             severity the system.LoggingLevel variable to determine the exception level
      * @return            void
      * @throws            NA
      */      
     public static void logHandledException(List<APS_ExceptionLog__e> lstExcpEvents){
        try{
            List<ExceptionLog__c> exceptions = new List<ExceptionLog__c>();
            for(APS_ExceptionLog__e excEvnt : lstExcpEvents){
                exceptions.add(buildExceptionObject(excEvnt));
            }
            List<ExceptionLog__c> mergeLogList = new List<ExceptionLog__c>();                          
            mergeLogList = mergeExistingErrorLogs(exceptions);
            APS_UTIL_LoggingService.insertExceptionList(mergeLogList);
        }catch(Exception excp){
            APS_UTIL_LoggingService.logHandledException(excp, UserInfo.getOrganizationId(), APS_UTIL_ErrorConstants.ERROR_APPLICATION, APS_UTIL_ErrorConstants.EXCEPTION_CLASS_UPDATED, APS_UTIL_ErrorConstants.EVENT_LOGHANDLE_EXCEP, null, LoggingLevel.ERROR);
        }       
     }

    /**
      * @description       This method is called by multiple methods, to check if the current ExceptionLog__c record can be merged with any pre-existing record if they have the same class and method name or trigger name. 
      * @param             exceptionLogList the List of Exceptions__c records to be inserted
      * @return            List<ExceptionLog__c>
      * @throws            NA
      */
     private static List<ExceptionLog__c> mergeExistingErrorLogs(List<ExceptionLog__c> exceptionLogList){         
         String lineColumn = APS_UTIL_ErrorConstants.BLANK_SPACE;         
         List<String> exceptionType = new List<String>();                
         List<ExceptionLog__c> existingExceptionLogs   = new List<ExceptionLog__c>();
         List<ExceptionLog__c> exExcpLogs = new List<ExceptionLog__c>();
         List<ExceptionLog__c> exceptionLogToBeUpdated = new List<ExceptionLog__c>();
         List<ExceptionLog__c> exceptionLogToBeInserted = new List<ExceptionLog__c>();
         Set<ExceptionLog__c> logList = new Set<ExceptionLog__c>();         
         string excpType = NULL;
         for(ExceptionLog__c excp: exceptionLogList){
             excpType=excp.ExceptionType__c;
             exceptionType.add(excpType);
         }          
         existingExceptionLogs = [SELECT Id, Name, ApexTrigger__c, MethodName__c, ClassName__c, ExceptionDetails__c, 
                                         ExceptionLogTimestamp__c, NumberOfTimesOccured__c, ContextUser__c,
                                         WSCallingApplication__c, WSCallingArea__c, WSTransactionID__c, ExceptionType__c 
                                  FROM ExceptionLog__c
                                  WHERE ExceptionType__c IN: exceptionType LIMIT 50000];                            
         for(ExceptionLog__c excp: exceptionLogList){
             exExcpLogs = new List<ExceptionLog__c>();
             if(String.isNotBlank(excp.ExceptionDetails__c) && excp.ExceptionDetails__c.contains(APS_UTIL_ErrorConstants.LINE_NO)){
                 lineColumn = excp.ExceptionDetails__c.substring(0, excp.ExceptionDetails__c.IndexOf(APS_UTIL_ErrorConstants.LINE_NO));
             }
             else{
                 lineColumn = excp.ExceptionDetails__c;
             }
             if(String.isNotBlank(excp.ExceptionType__c)){
                 for(ExceptionLog__c  exExcp : existingExceptionLogs){
                     if(excp.ExceptionType__c.equalsIgnoreCase(exExcp.ExceptionType__c)){
                         exExcpLogs.add(exExcp);
                     }
                 }  
             } 
             logMergeException(exExcpLogs, lineColumn, excp, exceptionLogToBeUpdated, exceptionLogToBeInserted );
         }
         if(!exceptionLogToBeupdated.isEmpty()){
             Map<Id,ExceptionLog__c> exceptionLogToBeupdatedMap=new Map<Id,ExceptionLog__c>();
             logList.addAll(exceptionLogToBeupdated);
             exceptionLogToBeupdated.clear();
             exceptionLogToBeupdated.addAll(logList);
             exceptionLogToBeupdatedMap.putall(exceptionLogToBeupdated);
             Database.update(exceptionLogToBeupdated, false);
         }
         return exceptionLogToBeInserted;
     }
     
    /**
      * @description       This method is called by mergeExistingErrorLogs method, to update the pre-existing ExceptionLog__c record which is to be merged with the new ExceptionLog__c record.  
      * @param             existingErrorLogs the List of pre-existing ExceptionLog__c records
      * @param             lineColumn the String containing the edited errorDescription
      * @param             newExcp the ExceptionLog__c record to be inserted
      * @param             exceptionLogToBeUpdated the List of pre-existing ExceptionLog__c records to be updated
      * @param             exceptionLogToBeInserted the List of ExceptionLog__c records to be inserted
      * @return            void
      * @throws            Exception
      */
    private static void logMergeException(List<ExceptionLog__c> existingErrorLogs, String lineColumn, ExceptionLog__c newExcp,
                                           List<ExceptionLog__c> exceptionLogToBeUpdated, List<ExceptionLog__c> exceptionLogToBeInserted ){
         
        String excpDetails = APS_UTIL_ErrorConstants.BLANK_SPACE;
        
        for(ExceptionLog__c existingLog : existingErrorLogs) {
             
             if(String.isNotBlank(existingLog.ExceptionDetails__c) && existingLog.ExceptionDetails__c.contains(APS_UTIL_ErrorConstants.LINE_NO)){
                 excpDetails = existingLog.ExceptionDetails__c.substring(0, existingLog.ExceptionDetails__c.IndexOf(APS_UTIL_ErrorConstants.LINE_NO));
             }
             else{
                 excpDetails = existingLog.ExceptionDetails__c;
             }
             if(String.isNotBlank(excpDetails) && excpDetails.trim().equalsIgnoreCase(lineColumn.trim()) && 
            String.isNotBlank(existingLog.ContextUser__c) && (existingLog.ContextUser__c == newExcp.ContextUser__c) && 
            (existingLog.ExceptionLogTimestamp__c != null) && (existingLog.ExceptionLogTimestamp__c.date() == (System.now()).date()) &&
              (((String.isNotBlank(existingLog.ClassName__c) && existingLog.ClassName__c.equalsIgnoreCase(newExcp.ClassName__c)) && 
              (String.isNotBlank(existingLog.MethodName__c) && existingLog.MethodName__c.equalsIgnoreCase(newExcp.MethodName__c))) || (String.isNotBlank(existingLog.ApexTrigger__c) &&
               existingLog.ApexTrigger__c.equalsIgnoreCase(newExcp.ApexTrigger__c))) || ((String.isNotBlank(existingLog.WSCallingApplication__c) && 
               existingLog.ClassName__c.equalsIgnoreCase(newExcp.WSCallingApplication__c)) && (String.isNotBlank(existingLog.WSCallingArea__c) &&
                existingLog.ClassName__c.equalsIgnoreCase(newExcp.WSCallingArea__c)))){    
                 existingLog.ExceptionDetails__c = newExcp.ExceptionDetails__c ;                
                 existingLog.NumberOfTimesOccured__c = (existingLog.NumberOfTimesOccured__c == null?1:existingLog.NumberOfTimesOccured__c) + 1;
                 existingLog.ExceptionLogTimestamp__c = System.Now();
                 existingLog.ContextUser__c = newExcp.ContextUser__c;
                 existingLog.WSTransactionID__c = newExcp.WSTransactionID__c ;
                 existingLog.APS_Unique_Id__c = newExcp.APS_Unique_Id__c;
                 exceptionLogToBeUpdated.add(existingLog);                 
             }               
         } 
                
         if(exceptionLogToBeUpdated.isEmpty()){ 
             exceptionLogToBeInserted.add(newExcp);
         } 
     }   
    
    /**
      * @description       This method is used to build the ExceptionLog__c record to be inserted.  
      * @param             excp the Exception object
      * @param             orgID the organization ID
      * @param             applicationName the Application Name
      * @param             className the Class Name
      * @param             methodName the Method Name
      * @param             severity the system.LoggingLevel variable to determine the exception level
      * @param             apexErrMsg the String containing error Message (for unhandledException)
      * @param             exceptionName the String containing exception type (for unhandledException)
      * @param             triggerName the String containing Trigger Name (for unhandledException)
      * @param             severityVal the String containing severity level value (for unhandledException)
      * @param             user the String containing logged in User ID (for unhandledException)
      * @param             codeSnippet the String containing the exception code (for unhandledException)
      * @param             handled the Boolean value to determine if it is handled exception or unhandled
      * @return            ExceptionLog__c
      * @throws            NA
      */
     private static ExceptionLog__c buildExceptionObject(APS_ExceptionLog__e excEvnt){
         ExceptionLog__c exceptionLog = new ExceptionLog__c();
         exceptionLog.ExceptionDetails__c = buildExceptionDetails(excEvnt.APS_Exception_Type__c,excEvnt.APS_Exception_Description__c,excEvnt.APS_Exception_Details__c);
         exceptionLog.OrgId__c = excEvnt.APS_OrgId__c;
         exceptionLog.ExceptionType__c = excEvnt.APS_Exception_Type__c;
         exceptionLog.Application__c = excEvnt.APS_Application_Name__c;
         exceptionLog.ClassName__C = excEvnt.APS_Class_Name__c;
         exceptionLog.MethodName__c = excEvnt.APS_Method_Name__c;
         exceptionLog.ApexTrigger__c = excEvnt.APS_Apex_Trigger__c;
         exceptionLog.ContextUser__c = excEvnt.APS_ContextUser__c;
         exceptionLog.Severity__c = excEvnt.APS_Severity__c;
         exceptionLog.ExceptionCode__c = excEvnt.APS_Exception_Code__c;
         exceptionLog.ExceptionDescription__c = excEvnt.APS_Exception_Description__c; //.left(APS_UTIL_ErrorConstants.EXCEPTION_CODE_SIZE_LIMIT)
         exceptionLog.ExceptionLogTimeStamp__c = System.now();
         exceptionLog.isHandled__c = excEvnt.APS_Is_Handled__c;
         exceptionLog.NumberOfTimesOccured__c = 1;
         exceptionLog.APS_Unique_Id__c = excEvnt.APS_Unique_Id__c;
    
         return exceptionLog;
     }
          
    /**
      * @description       This method is used to build the ExceptionDetail__c field value for ExceptionLog__c record to be inserted.  
      * @param             excp the Exception object
      * @return            String
      * @throws            NA
      */ 
     private static String buildExceptionDetails(string typeName,string msg,string stackTrace){
        string details = stackTrace;
         return details.left(APS_UTIL_ErrorConstants.EXCEPTION_DETAILS_SIZE_LIMIT);
     }
    
}