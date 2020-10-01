/**
@Author : Parasuram Basi
@Name: APS_LogExceptionEventCls 
@CreatedDate: 05 - Oct 2018
@Description: APS_LogExceptionEventCls class called from related classes catch block to create exception log record
@version : 1.0  
*/
public without sharing class APS_LogExceptionEventCls{
    public static Integer retries = 0;
    public static String prevClassMethod = '';
    public static List<String> lstValidExceptions = new List<String>{'FIELD_CUSTOM_VALIDATION_EXCEPTION','REQUIRED_FIELD_MISSING'};
    public static Boolean flag=false;
    public static String exceptionMsg=NULL;
    private static final string CHECKVALIDEXCEPTION='checkValidException';
    private static final string CLASSNAME='APS_LogExceptionEventCls';
    /**
    @Description: LogExceptionEvent() method 
    @Name : LogExceptionEvent
    @Param : exception e,string ClsName,string MethodNme
    @Return : void
    @throws Exception : N/A;
    */
    public static String logExceptionEvent(exception e,string ClsName,string MethodNme){
        String errorMsg = NULL;
        if(!APS_ErrorHandlingFramework__c.getOrgDefaults().APS_Stop_Handle_Exceptions__c){
            List<APS_ExceptionLog__e> errorMessages = new List<APS_ExceptionLog__e>();
            System.debug('====Exception===>'+e.getMessage());
            System.debug('====Exception===>'+e.getStackTraceString());
            try{
              if(!flag){
               
                errorMessages.add(buildExceptionObject(e, UserInfo.getOrganizationId(), null, ClsName, MethodNme, LoggingLevel.ERROR, null, null, null,null , userinfo.getUserId(), null,  true));
              
                List<Database.SaveResult> results = EventBus.publish(errorMessages); 
                flag=true;               
                //errorMsg = errorMessages[0].APS_Exception_Description__c +' - Ref No: '+errorMessages[0].APS_Unique_Id__c;
                //  errorMsg = System.Label.APS_Admin_Exception_Message +' - Ref No: '+errorMessages[0].APS_Unique_Id__c;                 
      //errorMsg = checkValidException(errorMessages[0].APS_Exception_Description__c,) +' - Ref No: '+errorMessages[0].APS_Unique_Id__c;
      errorMsg = checkValidException(errorMessages[0].APS_Exception_Description__c,errorMessages[0].APS_Unique_Id__c); //+' - Ref No: '+errorMessages[0].APS_Unique_Id__c;
      exceptionMsg =errorMsg;
      }else{
        errorMsg = exceptionMsg;
      }
            }catch(exception excp){            
                 APS_UTIL_LoggingService.logHandledException(excp, UserInfo.getOrganizationId(), APS_UTIL_ErrorConstants.ERROR_APPLICATION, APS_UTIL_ErrorConstants.ERROR_LOG_CLASS, APS_UTIL_ErrorConstants.UNHANDLED_ERROR_LOG_METHOD, null, LoggingLevel.ERROR);
            }
        }
        return errorMsg;
    }
      /**
      * @description       This method is used to check the exception type and send the message to the UI level
      * @return            Sends the appropriate message
      * @throws            NA
      */
    public static String checkValidException(String excpMessage,String refId){
        try{
      String errorMsg = NULL;
      Boolean hasValid = False;
      for(String excpString : lstValidExceptions){
        if(excpMessage.containsIgnoreCase(excpString)){
          hasValid = True;          
          break;
        }
      }
      if(hasValid){
        errorMsg = System.Label.APS_Admin_Exception_Message+'Ref Id :'+refId+' '+excpMessage;
      }else{
        errorMsg =  System.Label.APS_Admin_Exception_Message+'Ref Id:'+refId;
      }
      return errorMsg;
        }
        Catch(Exception e){    
            APS_LogExceptionEventCls.logExceptionEvent(e,CLASSNAME,CHECKVALIDEXCEPTION);
            return null;
        }
    }
    
    /**
      * @description       This method is called in case of an unhandled Exception. This method in turn calls processExceptionEmail method to build and insert ExceptionLog__c records.
      * @param             email A reference to the Messaging.InboundEmail object
      * @return            void
      * @throws            NA
      */
     public static void logUnhandledException(Messaging.InboundEmail email){
         try{
             if(!APS_ErrorHandlingFramework__c.getOrgDefaults().APS_Stop_Handle_Exceptions__c){
                 Boolean isSandBoxEmail = false;
                 if((email.subject.contains(APS_UTIL_ErrorConstants.SANDBOX_EMAIL) || email.plainTextBody.contains(APS_UTIL_ErrorConstants.SANDBOX_EMAIL))){
                     isSandboxEmail = true;           
                 }
                 processExceptionEmail(email, isSandboxEmail);
             }
         }catch(Exception excp){
             APS_UTIL_LoggingService.logHandledException(excp, UserInfo.getOrganizationId(), APS_UTIL_ErrorConstants.ERROR_APPLICATION, APS_UTIL_ErrorConstants.ERROR_LOG_CLASS, APS_UTIL_ErrorConstants.EVENT_LOGUNHANDLED, null, LoggingLevel.ERROR);
         }
     }
     
     /**
      * @description       This method is called by logUnhandledException method. This method builds and inserts APS_ExceptionLog__e records. Also checks if this record can be merged with any pre-existing record.
      * @param             email A reference to the Messaging.InboundEmail object
      * @param             isSandboxEmail the boolean variable to determine if email is generated by a sandbox environment
      * @return            void
      * @throws            Exception
      */
     private static void processExceptionEmail(Messaging.InboundEmail email, boolean isSandboxEmail){
         //Variables for Exception Details
         String mailSub=APS_UTIL_ErrorConstants.BLANK_SPACE;
         String emailBody = email.plainTextBody;
         String exceptionName=APS_UTIL_ErrorConstants.BLANK_SPACE;
         String codeSnippet=APS_UTIL_ErrorConstants.BLANK_SPACE;     
         String triggerName=APS_UTIL_ErrorConstants.BLANK_SPACE;
         String className=APS_UTIL_ErrorConstants.BLANK_SPACE;
         String methodName=APS_UTIL_ErrorConstants.BLANK_SPACE;
         String user = APS_UTIL_ErrorConstants.BLANK_SPACE;
         String orgId = APS_UTIL_ErrorConstants.BLANK_SPACE;
         String apexErrMsg = APS_UTIL_ErrorConstants.BLANK_SPACE;   
         //End of Variables for Exception Details
         
         List<APS_ExceptionLog__e> exceptionLogList = new List<APS_ExceptionLog__e>();                 
         APS_ExceptionLog__e exceptionLog = new APS_ExceptionLog__e();
        
         try{
            // Method call to get the mail Subject
            mailSub = APS_UTIL_LoggingService.mailSubjectVal(email, isSandboxEmail);
             
             // Method to get the code snippet
            codeSnippet = APS_UTIL_LoggingService.codeSnipVal(mailSub);
            
            // Method to get the type of exception thrown
            exceptionName = APS_UTIL_LoggingService.exceptionType(mailSub, emailBody);
             
             // Method to get only the Original Error msg
            apexErrMsg = APS_UTIL_LoggingService.errorMessage(emailBody);
            // Logic to get the Apex Class name and Method name if there any
            if(apexErrMsg.contains(APS_UTIL_ErrorConstants.PREFIX_CLASS)){
                 className = apexErrMsg.substring(apexErrMsg.indexOf(APS_UTIL_ErrorConstants.PREFIX_CLASS) + APS_UTIL_ErrorConstants.PREFIX_CLASS.length());
                 methodName = className.substring(className.indexOf(APS_UTIL_ErrorConstants.FULLSTOP)+1, className.indexOf(APS_UTIL_ErrorConstants.COLON)).trim();
                 className = className.substring(0, className.indexOf(APS_UTIL_ErrorConstants.FULLSTOP)).trim();
             }
             
             // Logic to get Apex Trigger name if there is any
             if(apexErrMsg.contains(APS_UTIL_ErrorConstants.PREFIX_TRIGGER)){
                 triggerName = apexErrMsg.substring(apexErrMsg.indexOf(APS_UTIL_ErrorConstants.PREFIX_TRIGGER) + APS_UTIL_ErrorConstants.PREFIX_TRIGGER.length());
                 triggerName = triggerName.substring(0, triggerName.indexOf(APS_UTIL_ErrorConstants.COLON)).trim();
             }
             
             // Logic to get the Context User and The Organization Id
             if(apexErrMsg.contains(APS_UTIL_ErrorConstants.USER)){
                 user = apexErrMsg.subString(apexErrMsg.indexOf(APS_UTIL_ErrorConstants.USER)+APS_UTIL_ErrorConstants.USER.length());
                 String userId = user.subString(user.indexOf(APS_UTIL_ErrorConstants.COLON)+1,user.indexOf(APS_UTIL_ErrorConstants.FORWARD_SLASH)).trim();
                 orgId = user.subString(user.indexOf(APS_UTIL_ErrorConstants.FORWARD_SLASH)+1,user.indexOf(APS_UTIL_ErrorConstants.FORWARD_SLASH)+userId.length()+1).trim();
                 user = userId;
             }
             //System.debug('@@@APS_LogExceptionEventCls :processExceptionEmail : before buildExceptionObject ');
             exceptionLogList.add(buildExceptionObject(null, orgId, null, className, methodName, null, apexErrMsg, exceptionName, triggerName,
                                                    APS_UTIL_ErrorConstants.SEVERITY_LEVEL_ERROR , 
                                                    user, codeSnippet,  false));
             if(exceptionLogList != null && !exceptionLogList.isEmpty()){
                 List<Database.SaveResult> results = EventBus.publish(exceptionLogList);
             }                    
         }
         catch(Exception excp){
             APS_UTIL_LoggingService.logHandledException(excp, UserInfo.getOrganizationId(), APS_UTIL_ErrorConstants.ERROR_APPLICATION, APS_UTIL_ErrorConstants.ERROR_LOG_CLASS, APS_UTIL_ErrorConstants.UNHANDLED_ERROR_LOG_METHOD, null, LoggingLevel.ERROR);
         }
     }
    
    /**
    @Description: reTryCallingMethod() method 
    @Name : reTryCallingMethod
    @Param : exception e,string ClsName,string MethodNme
    @Return : boolean
    @throws Exception : N/A;
    */
    public static boolean reTryException(exception excp, String className, String methodName){
        String combi = className + '-' + methodName;        
        Boolean retry = False;
        try{
            for(APS_Retry_Exception__mdt retryMeta : [Select id,DeveloperName,APS_Exception_Message__c FROM APS_Retry_Exception__mdt LIMIT 10000]){
                if(retryMeta.APS_Exception_Message__c != NULL && excp.getTypeName().containsIgnoreCase(retryMeta.APS_Exception_Message__c)){
                    retry = True;
                    break;
                }
            }
            if(combi != prevClassMethod){
                prevClassMethod = combi;
                retries = 0;
            }else{
                retries++;
            }
        }catch(Exception exp){
            APS_UTIL_LoggingService.logHandledException(exp, UserInfo.getOrganizationId(), APS_UTIL_ErrorConstants.ERROR_APPLICATION, APS_UTIL_ErrorConstants.EXCEPTION_EVENT_CLASS, APS_UTIL_ErrorConstants.EVENT_RETRY_EXCEPTION, null, LoggingLevel.ERROR);
        }
        return retry;       
    }
    
    /**
      * @description       This method logs ExceptionLog__c records in case of Exception obtained due to Database.SaveResult or Database.DeleteResult operation.
      * @param             svResults A List of Database.Saveresult object records
      * @param             delResults A List of Database.Deleteresult object records
      * @param             objs A List of sObject records which threw the exception when being saved
      * @param             appName the Application Name
      * @param             className the Class Name
      * @param             methodName the Method Name
      * @param             triggerName the Trigger Name
      * @param             level the system.LoggingLevel variable to determine the exception level
      * @return            void
      * @throws            NA
      */
     public static void logDmlResults(List<Database.Saveresult> svResults, List<Database.DeleteResult> delResults, 
                                      List<sObject> objs, String appName, String className, String methodName, String triggerName){
         try{
             List<APS_ExceptionLog__e>  exceptionLogList = new List<APS_ExceptionLog__e>();
             // Method called in case of save exception
             if(svResults!=null && delResults==null){
                 exceptionLogList = createExceptionForSaveResults(svResults, objs, appName, className, methodName, triggerName);
             }         
             // Method called in case of delete exception
             else if(delResults!=null && svResults==null){
                 exceptionLogList = createExceptionsForDeleteResults(delResults, objs, appName, className, methodName, triggerName);
             }
             
            if (exceptionLogList.size() > 0) {
                List<Database.SaveResult> results = EventBus.publish(exceptionLogList);
            }
        }catch(Exception excp){
            APS_UTIL_LoggingService.logHandledException(excp, UserInfo.getOrganizationId(), APS_UTIL_ErrorConstants.ERROR_APPLICATION, APS_UTIL_ErrorConstants.EXCEPTION_EVENT_CLASS, APS_UTIL_ErrorConstants.EVENT_LOGDML_RESULTS, null, LoggingLevel.ERROR);
        }
     }
     
     
    /**
      * @description       This method creates APS_ExceptionLog__e records in case of Exception obtained due to Database.SaveResult operation.
      * @param             svResults A List of Database.Saveresult object records
      * @param             relatedsObjects A List of sObject records which threw the exception when being saved
      * @param             appName the Application Name
      * @param             className the Class Name
      * @param             methodName the Method Name
      * @param             triggerName the Trigger Name
      * @param             level the system.LoggingLevel variable to determine the exception level
      * @return            List<APS_ExceptionLog__e>
      * @throws            NA
      */
     private static List<APS_ExceptionLog__e> createExceptionForSaveResults(List<Database.SaveResult> saveResults, 
                                                                        List<sObject> relatedsObjects, String appName, 
                                                                        String className, string methodName, String triggerName) {
         List<APS_ExceptionLog__e> exceptionLogList = new List<APS_ExceptionLog__e>();
         APS_ExceptionLog__e excepRecord = new APS_ExceptionLog__e();            
             for(integer i=0; i <saveResults.size(); ++i) {
                 Database.SaveResult saveresult = saveResults[i];
                 if(!saveresult.isSuccess()) {
                     Database.Error[] errors = saveresult.getErrors();
                     String relatedObjectString = APS_UTIL_ErrorConstants.BLANK_SPACE;
                     if (relatedsObjects.size() > i) {
                         relatedObjectString = APS_UTIL_ErrorConstants.RELATED_OBJECT + relatedsObjects[i];
                     }
                     String errorMessage = (APS_UTIL_LoggingService.buildErrorMessageFromErrorList(saveresult.getId(), errors) + 
                                            relatedObjectString.left(APS_UTIL_ErrorConstants.EXCEPTION_DETAILS_SIZE_LIMIT));
                     
                     String exceptionCode = APS_UTIL_ErrorConstants.BLANK_SPACE;
                     if (errors.size() > 0) {
                         exceptionCode = errors[0].statusCode.name();
                     }
                     excepRecord = new APS_ExceptionLog__e(APS_Application_Name__c = appName , APS_Exception_Code__c=exceptionCode, 
                                                              APS_Class_Name__c = className, APS_Method_Name__c = methodName, APS_Number_of_Times_Occured__c=1,
                                                              APS_Exception_Log_Timestamp__c = System.Now(), APS_Apex_Trigger__c=triggerName, 
                                                              APS_Exception_Details__c = errorMessage, APS_Severity__c = 'ERROR',
                                                              APS_Exception_Type__c = APS_UTIL_ErrorConstants.DML_EXCEPTION, APS_Is_Handled__c = true,
                                                              APS_ContextUser__c = UserInfo.getUserId(),APS_Exception_Description__c = errors[0].getMessage());
                    
                    exceptionLogList.add(excepRecord);
                 }
             }
         return exceptionLogList;    
     }
     
    /**
      * @description       This method creates APS_ExceptionLog__e records in case of Exception obtained due to Database.DeleteResult operation.
      * @param             deleteResults A List of Database.DeleteResult object records
      * @param             relatedsObjects A List of sObject records which threw the exception when being saved
      * @param             appName the Application Name
      * @param             className the Class Name
      * @param             methodName the Method Name
      * @param             triggerName the Trigger Name
      * @param             level the system.LoggingLevel variable to determine the exception level
      * @return            List<APS_ExceptionLog__e>
      * @throws            NA
      */
     private static List<APS_ExceptionLog__e> createExceptionsForDeleteResults(List<Database.DeleteResult> deleteResults, 
                                                                           List<sObject> relatedsObjects, String appName, 
                                                                           String className, String methodName, String triggerName) {
         List<APS_ExceptionLog__e> exceptionLogList = new List<APS_ExceptionLog__e>();
         APS_ExceptionLog__e excepRecord = new APS_ExceptionLog__e();           
             for(integer i = 0; i < deleteResults.size(); ++i) {
                 Database.DeleteResult delResults = deleteResults[i];
                 if(!delResults.isSuccess()) {
                     Database.Error[] errors = delResults.getErrors();
                     String relatedObjectString = APS_UTIL_ErrorConstants.BLANK_SPACE;
                     if (relatedsObjects.size() > i) {
                             relatedObjectString = APS_UTIL_ErrorConstants.RELATED_OBJECT + relatedsObjects[i];
                     }
                     String errorMessage = (APS_UTIL_LoggingService.buildErrorMessageFromErrorList(delResults.getId(), errors) + 
                                                relatedObjectString.left(APS_UTIL_ErrorConstants.EXCEPTION_DETAILS_SIZE_LIMIT));                    
                     String exceptionCode = APS_UTIL_ErrorConstants.BLANK_SPACE;
                     if (errors.size() > 0){
                         exceptionCode = errors[0].statusCode.name();
                     }
                     excepRecord = new APS_ExceptionLog__e(APS_Application_Name__c = appName , APS_Exception_Code__c=exceptionCode, 
                                                              APS_Class_Name__c = className, APS_Method_Name__c = methodName, APS_Number_of_Times_Occured__c=1,
                                                              APS_Exception_Log_Timestamp__c = System.Now(), APS_Apex_Trigger__c=triggerName, 
                                                              APS_Exception_Details__c = errorMessage, APS_Severity__c = 'ERROR',
                                                              APS_Exception_Type__c = APS_UTIL_ErrorConstants.DML_EXCEPTION, APS_Is_Handled__c = true,
                                                              APS_ContextUser__c = UserInfo.getUserId(),APS_Exception_Description__c = errors[0].getMessage());
                      exceptionLogList.add(excepRecord);
                 }
             }
         return exceptionLogList;
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
      * @return            APS_ExceptionLog__e
      * @throws            NA
      */ 
     private static APS_ExceptionLog__e buildExceptionObject(Exception excp, String orgID, String applicationName, String className, 
                                                        String methodName, System.LoggingLevel severity, String apexErrMsg, String exceptionName, 
                                                        String triggerName, String severityVal, String user, String codeSnippet, Boolean handled){
         Map<String,String> mapSeverityVal = getSeverityValues();
         APS_ExceptionLog__e exceptionLog = new APS_ExceptionLog__e();
         exceptionLog.APS_Exception_Details__c = handled?APS_UTIL_LoggingService.buildExceptionDetails(excp):apexErrMsg;
         exceptionLog.APS_OrgId__c = orgID;
         exceptionLog.APS_Exception_Type__c = handled?excp.getTypeName():exceptionName;
         exceptionLog.APS_Application_Name__c = applicationName;
         exceptionLog.APS_Class_Name__c = className;
         exceptionLog.APS_Method_Name__c = methodName;
         exceptionLog.APS_Apex_Trigger__c = triggerName;
         exceptionLog.APS_ContextUser__c = handled?UserInfo.getUserId():[SELECT Id FROM User WHERE ID=: user LIMIT 1].Id;
         exceptionLog.APS_Unique_Id__c= APS_UnqIdGeneratorForErrorHandling();
         if(mapSeverityVal.containsKey(exceptionLog.APS_Exception_Type__c)){
             exceptionLog.APS_Severity__c = mapSeverityVal.get(exceptionLog.APS_Exception_Type__c);
         }else{
             exceptionLog.APS_Severity__c = APS_UTIL_ErrorConstants.SEVERITY_LEVEL_ERROR;
         }         
         if(handled){
             Integer startPoint = excp.getMessage().IndexOf(APS_UTIL_ErrorConstants.EXCEPTION_CODE_FILTER)+APS_UTIL_ErrorConstants.EXCEPTION_CODE_FILTER.length();
             //system.debug('@@@ startPoint--> '+startPoint);
             String excpCode = excp.getMessage().substring(startPoint).trim();
             //system.debug('@@@ excpCode--> '+excpCode);
             excpCode = (excpCode.split(APS_UTIL_ErrorConstants.BLANK_SPACE))[0];
            // system.debug('@@@ excpCode after split--> '+excpCode);
             exceptionLog.APS_Exception_Code__c = excpCode.left(excpCode.length()-1);
             //system.debug('@@@ exceptionLog.APS_Exception_Code__c--> '+exceptionLog.APS_Exception_Code__c);
         }
         else{
             exceptionLog.APS_Exception_Code__c = codeSnippet;
         }
         exceptionLog.APS_Exception_Description__c = handled?excp.getMessage():codeSnippet; //.left(APS_UTIL_ErrorConstants.EXCEPTION_CODE_SIZE_LIMIT)
         exceptionLog.APS_Exception_Log_Timestamp__c = System.now();
         exceptionLog.APS_Is_Handled__c = handled;
         exceptionLog.APS_Number_of_Times_Occured__c = 1;
    
         return exceptionLog;
     }
     
      /**
      * @description       This method is used to return Exception Severity values.
      * @return            Map of Exception type with Severity Values
      * @throws            NA
      */
     Private static Map<String,String> getSeverityValues(){
         Map<String,String> mapErrorTypeSeverity = new Map<String,String>();
         for(APS_ExceptionSeverity__mdt sev : [Select id,APS_ErrorMessage__c,APS_Severity__c From APS_ExceptionSeverity__mdt LIMIT 1000]){
             mapErrorTypeSeverity.put(sev.APS_ErrorMessage__c,sev.APS_Severity__c);
         }
         return mapErrorTypeSeverity;
     }
      /**
      * @description       This method is used to return the value with the unique Id generator.
      * @return            returns a unique Id based on the time stamp
      * @throws            NA
      */
     private static String APS_UnqIdGeneratorForErrorHandling() {
         Datetime dt=Datetime.now();
         long st=dt.getTime();
         String unqId=st.format();
         unqId=unqId.replaceAll(',','');
         /*DateTime myDateTime = datetime.now();
         integer secs=myDateTime.second();
         integer ms=myDateTime.millisecond();
         String unqId = myDateTime.format();
         unqId = unqId.replace('/', '');
        unqId = unqId.replace(':', '');
        unqId = unqId.replace('AM', '0');
        unqId = unqId.replace('PM', '1');
        unqId = unqId.deleteWhitespace();
        unqId=unqId+secs+ms;
        if (unqId.Length() == 11) {
            unqId = unqId + '0000000';
        } else if (unqId.Length() == 12) {
            unqId = unqId + '000000';
        } else if (unqId.Length() == 13) {
            unqId = unqId + '00000';
        } else if (unqId.Length() == 14) {
           unqId = unqId + '0000';
        } else if (unqId.Length() == 15){
          unqId =unqId + '000';
        } else if (unqId.length() == 16){
          unqId = unqId + '00';
        } else if(unqId.Length() ==17){
          unqId = unqId + '0';
        }*/
        /*APS_ExceptionLog__e excep=new APS_ExceptionLog__e();
        excep.Unique_Id2__c=unqId;
        ExceptionLog__c logEx=new ExceptionLog__c();
        logEx.Unique_Id__c=unqId;*/
        return unqId;
    }
}