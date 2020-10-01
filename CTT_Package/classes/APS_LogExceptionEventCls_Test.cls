/**
  * @author        Parasuram Basi
  * @date          10/16/2018
  * @description   Test Class for APS_LogExceptionEventCls class.
  */
@isTest(seeAllData=true)
private without sharing class APS_LogExceptionEventCls_Test{
    
    // Start of Constants for Test Methods
     
    private static final String UN_ALIAS = 'unEr';
    private static final String HN_ALIAS = 'hEr';
    private static final Integer NUM = 1;
    private static final String SYSTEM_ADMIN = 'System Administrator';
      private static final String TEST_EMAIL = 'automation@testapex.com';
    
    private static final String CLASS_ONE = 'CreateApexErrorLog';
    private static final String SUBJECT_ONE =  'Fwd: Force.com Sandbox: script exception from Accenture : '+
                                               'CreateApexErrorLog : Attempted to schedule too '+ 
                                               'many concurrent batch jobs in this org (limit is 5)';                                                
    private static final String BODY_ONE_A =  'Apex script unhandled exception by user/organization: ';
    private static final String BODY_ONE_B = ' /00D90000000fOLB caused by: System.Exception: Attempted to schedule too'+
                                            ' many concurrent batch jobs '+ 
                                            'Class.CreateApexErrorLog.execute: Debug Log: Starts';
    
    private static final String SUBJECT_TWO = 'Developer script exception from Accenture : CreateApexErrorLog : '+
                                              'Attempt to de-reference a null object';
    private static final String BODY_TWO_A = 'Apex script unhandled exception by user/organization: ';
    private static final String BODY_TWO_B = '/00D90000000fOLB Visualforce Page: /apex/flowfinishsecpage '+
                                             'caused by: System.NullPointerException: Attempt to de-reference a null object '+
                                             'Class.CreateApexErrorLog.dataSplit: line 132, column 1';
    
    private static final String CLASS_THREE = 'BeforeUpdate';
    private static final String SUBJECT_THREE = 'RE: Developer script exception from Test Org :BeforeUpdate: execution of AfterInsert';
    private static final String BODY_THREE_A = 'Apex script unhandled trigger exception by user/organization: ';
    private static final String BODY_THREE_B = ' /00D90000000fOLB exception by Test user Org System.QueryException: test: Trigger.BeforeUpdate: line 5, column 1';
    
    private static final String SUBJECT_FOUR_A = 'FW: Developer script exception from Test Org :';
    private static final String SUBJECT_FOUR_B = ' : List index out of bounds ';
    private static final String BODY_FOUR_A = 'Apex script unhandled exception by user/organization: ';
    private static final String BODY_FOUR_B = ' /00D90000000fOLB exception by Test user Org' +
                                              APS_UTIL_ErrorConstants.CAUSED_BY + 'System.ListException: List index out of bounds:' +
                                              APS_UTIL_ErrorConstants.PREFIX_CLASS;
    private static final String BODY_FOUR_C = '.testMethod: line 132, column 1'; 
    
    private static final String SUBJECT_SIX = 'Test:Subject:Exception';
    private static final String BODY_SIX = 'Test Body';
    
    private static final String TEST_ORG_ID = 'TestOrgId';
    private static final String TEST_APP = 'TestApp';
    private static final String TEST_CLASS = 'TestClass';
    private static final String TEST_METHOD = 'TestMethod';
    private static final String TEST_USER_ROLE = 'TestUserRole';
    
    // End of Constants for Test Methods
    
    /**
      * @description       Method to create Messaging.InboundEmail type test data. 
      * @param             subject Subject of the email
      * @param             body Body of the email
      * @return            Messaging.InboundEmail
      * @throws            NA
      */
    private static Messaging.InboundEmail emailData(String subject, String body){
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.subject = subject;
        email.plainTextBody = body;
        email.fromAddress = TEST_EMAIL;
        return email;
    }
    
    /**
      * @description       Method to create Custom Setting record to determine severity level. 
      * @param             NA
      * @return            void
      * @throws            NA
      */
    public static void severityLevelValue(){
        LogSeverityLevelValue__c logLevel = LogSeverityLevelValue__c.getInstance(UserInfo.getOrganizationId());
        logLevel.LoggingLevel__c=APS_UTIL_ErrorConstants.SEVERITY_LEVEL_ERROR;
        Upsert logLevel;  
    }
    
    
    /**
      * @description       This Test Method is to verify that ExceptionLog__c record is logged
                           in case of Email sent from Sandbox Environment due to an Unhandled Exception. 
      * @param             NA
      * @return            void
      * @throws            NA
      */
    private static testMethod void unhandledExceptionOne(){
        User runUser = APS_UTIL_TestMethods.runningUser(UN_ALIAS+NUM , SYSTEM_ADMIN);
        insert runUser; 
        severityLevelValue();
        String subject = SUBJECT_ONE;
        String body = APS_UTIL_ErrorConstants.START_APEX_SCRIPT + APS_UTIL_ErrorConstants.SANDBOX_EMAIL + BODY_ONE_A + runUser.Id + BODY_ONE_B;
                      
        Messaging.InboundEmail email1 = emailData(subject, body);         
        
        Test.startTest();
        System.runAs(runUser){
           APS_LogExceptionEventCls.logUnhandledException(email1);
        }
        Test.stopTest();
        
        ExceptionLog__c excpData = [SELECT Id, ClassName__c FROM ExceptionLog__c WHERE ClassName__c=:CLASS_ONE LIMIT 50000]; 
        System.assertEquals(excpData.ClassName__c, CLASS_ONE);
    }
    
    /**
      * @description       This Test Method is to verify that ExceptionLog__c record is logged
                           in case of Email sent due to an Unhandled Exception. 
      * @param             NA
      * @return            void
      * @throws            NA
      */
    private static testMethod void unhandledExceptionTwo(){
        User runUser = APS_UTIL_TestMethods.runningUser(UN_ALIAS+NUM+1 , SYSTEM_ADMIN);
        insert runUser; 
        severityLevelValue();
        String subject = SUBJECT_TWO;
        String body = BODY_TWO_A + runUser.Id + BODY_TWO_B;
                      
        Messaging.InboundEmail email2 = emailData(subject, body);         
        
        Test.startTest();
        System.runAs(runUser){
           APS_LogExceptionEventCls.logUnhandledException(email2);
        }
        Test.stopTest();
        
        ExceptionLog__c excpData = [SELECT Id, ClassName__c, ExceptionDetails__c FROM ExceptionLog__c WHERE ClassName__c=:CLASS_ONE LIMIT 50000]; 
        System.assertEquals(excpData.ClassName__c, CLASS_ONE);
    }
    
    /**
      * @description       This Test Method is to verify that ExceptionLog__c record is logged
                           in case of Email sent due to an Unhandled Exception by a Trigger. 
      * @param             NA
      * @return            void
      * @throws            NA
      */
    private static testMethod void unhandledExceptionThree(){
        User runUser = APS_UTIL_TestMethods.runningUser(UN_ALIAS+NUM+2 , SYSTEM_ADMIN);
        //insert runUser; 
        severityLevelValue();
        String subject = SUBJECT_THREE;
        String body = BODY_THREE_A + runUser.Id + BODY_THREE_B;
                      
        Messaging.InboundEmail email3 = emailData(subject, body);         
        
        Test.startTest();
        System.runAs(runUser){
           APS_LogExceptionEventCls.logUnhandledException(email3);
        }
        Test.stopTest();
        
       // ExceptionLog__c excpData = [SELECT Id, ApexTrigger__c FROM ExceptionLog__c WHERE ApexTrigger__c=: CLASS_THREE LIMIT 50000]; 
        //System.assertEquals(excpData.ApexTrigger__c, CLASS_THREE);
    }
    
    
    /**
      * @description       This Test Method is to verify that ExceptionLog__c record is logged
                           in case of Email sent due to an Unhandled Exception. 
      * @param             NA
      * @return            void
      * @throws            NA
      */
    private static testMethod void unhandledExceptionFour(){
        User runUser = APS_UTIL_TestMethods.runningUser(UN_ALIAS+NUM+3 , SYSTEM_ADMIN);
        insert runUser; 
        severityLevelValue();
        ApexClass className = [SELECT Id, Name FROM ApexClass LIMIT 1];
        String subject = SUBJECT_FOUR_A + className.Name + SUBJECT_FOUR_B;
        String body = BODY_FOUR_A + runUser.Id + BODY_FOUR_B + className.Name + BODY_FOUR_C;
                      
        Messaging.InboundEmail email4 = emailData(subject, body);
        
        Test.startTest();
        System.runAs(runUser){
           APS_LogExceptionEventCls.logUnhandledException(email4);
        }
        Test.stopTest();
        
        ExceptionLog__c excpData = [SELECT Id, ClassName__c FROM ExceptionLog__c WHERE ClassName__c=:className.Name LIMIT 50000];
        System.assertEquals(excpData.ClassName__c, className.Name);
    }
    
    /**
      * @description       This Test Method is to verify that ExceptionLog__c record is logged due to handled exception thrown
                           when logging an Unhandled Exception in case of an Email sent due to an Unhandled Exception.
      * @param             NA
      * @return            void
      * @throws            NA
      */
    private static testMethod void unhandledExceptionFive(){
        User runUser = APS_UTIL_TestMethods.runningUser(UN_ALIAS+NUM+4 , SYSTEM_ADMIN);
        severityLevelValue();        
        String subject = APS_UTIL_ErrorConstants.BLANK_SPACE;
        String body = APS_UTIL_ErrorConstants.BLANK_SPACE;
                      
        Messaging.InboundEmail email5 = emailData(subject, body);
        
        Test.startTest();
        System.runAs(runUser){
           APS_LogExceptionEventCls.logUnhandledException(email5);
        }
        Test.stopTest();
        
        ExceptionLog__c excpData = [SELECT Id, ClassName__c FROM ExceptionLog__c WHERE MethodName__c=:APS_UTIL_ErrorConstants.UNHANDLED_ERROR_LOG_METHOD LIMIT 50000]; 
        
        System.assertEquals(excpData.ClassName__c , APS_UTIL_ErrorConstants.ERROR_LOG_CLASS);
    }
    
    /**
      * @description       This Test Method is to verify that ExceptionLog__c record is logged 
                           in case of an Email sent due to an Unhandled Exception. 
      * @param             NA
      * @return            void
      * @throws            NA
      */
    private static testMethod void unhandledExceptionSix(){
        User runUser = APS_UTIL_TestMethods.runningUser(UN_ALIAS+NUM+5 , SYSTEM_ADMIN);
        severityLevelValue();        
        String subject = SUBJECT_SIX;
        String body = BODY_SIX;
                      
        Messaging.InboundEmail email6 = emailData(subject, body);
        
        Test.startTest();
        System.runAs(runUser){
           APS_LogExceptionEventCls.logUnhandledException(email6);
        }
        Test.stopTest();
        
        Integer excpDataCount = [SELECT COUNT() FROM ExceptionLog__c LIMIT 50000]; 
        //System.assertNotEquals(excpDataCount , 1);
    }
    
    /**
      * @description       This Test Method is to verify that ExceptionLog__c record is logged 
                           in case of any program throwing a Handled Exception. 
      * @param             NA
      * @return            void
      * @throws            NA
      */
    private static testMethod void handledException(){
        User runUser = APS_UTIL_TestMethods.runningUser(HN_ALIAS+NUM , SYSTEM_ADMIN);
        severityLevelValue();
        try{
            Account testData = new Account();
            insert(testData);           
        }
        catch(DMLException excp){        
            Test.startTest();
            System.runAs(runUser){
               APS_LogExceptionEventCls.logExceptionEvent(excp,TEST_CLASS, TEST_METHOD);
            }
            Test.stopTest();
        }
        ExceptionLog__c excpData = [SELECT ClassName__c, Severity__c FROM ExceptionLog__c WHERE ClassName__c=:TEST_CLASS LIMIT 1]; 
        System.assertEquals(excpData.ClassName__c, TEST_CLASS);
    }
    
    /**
      * @description       This Test Method is to verify that ExceptionLog__c record is merged with an existing ExceptionLog__c record
                           in case of any program throwing a Handled Exception. 
      * @param             NA
      * @return            void
      * @throws            NA
      */
    private static testMethod void handledExceptionMerge(){
        User runUser = APS_UTIL_TestMethods.runningUser(HN_ALIAS+NUM+1 , SYSTEM_ADMIN);
        severityLevelValue();
        try{
            Account testData1 = new Account();
            insert(testData1);           
        }
        catch(DMLException excp){                    
            try{
                Account testData2 = new Account();
                insert(testData2);           
            }
            catch(DMLException dmlExcp){
                Test.startTest();
                System.runAs(runUser){
                   APS_LogExceptionEventCls.logExceptionEvent(excp,TEST_CLASS, TEST_METHOD);
                   APS_LogExceptionEventCls.logExceptionEvent(dmlExcp,TEST_CLASS, TEST_METHOD);
                }
                Test.stopTest();
            }
        }
        ExceptionLog__c excpData = [SELECT ClassName__c,NumberOfTimesOccured__c FROM ExceptionLog__c WHERE ClassName__c=:TEST_CLASS LIMIT 1]; 
        System.assertEquals(excpData.ClassName__c, TEST_CLASS);
    }
    
    /**
      * @description       This Test Method is to verify that ExceptionLog__c record is logged 
                           in case of any program throwing an Exception due to Database.insert() operation. 
      * @param             NA
      * @return            void
      * @throws            NA
      */
    private static testMethod void handledExceptionSave(){
        User runUser = APS_UTIL_TestMethods.runningUser(HN_ALIAS+NUM+2 , SYSTEM_ADMIN);
        severityLevelValue();
        List<Account> accList = new List<Account>();
        Account accData1= new Account(Name = TEST_USER_ROLE+NUM);
        Account accData2= new Account();
        accList.add(accData1);
        accList.add(accData2);
        Database.SaveResult[] svRes = Database.insert(accList, false);          
                
        Test.startTest();
        System.runAs(runUser){
           APS_LogExceptionEventCls.logDmlResults(svRes, null, accList, TEST_APP, TEST_CLASS, TEST_METHOD, null);
        }
        Test.stopTest();
        
        ExceptionLog__c excpData = [SELECT ClassName__c, Severity__c FROM ExceptionLog__c WHERE Application__c=:TEST_APP LIMIT 50000]; 
        System.assertEquals(excpData.ClassName__c, TEST_CLASS);
        Integer noOfExcep = [SELECT COUNT() FROM ExceptionLog__c WHERE Application__c=:TEST_APP LIMIT 50000];
        System.assertEquals(noOfExcep, 1);
    }

    /**
      * @description       This Test Method is to verify that ExceptionLog__c record is logged 
                           in case of any program throwing an Exception due to Database.delete() operation. 
      * @param             NA
      * @return            void
      * @throws            NA
      */
    private static testMethod void handledExceptionDelete(){
        User runUser = APS_UTIL_TestMethods.runningUser(HN_ALIAS+NUM+3 , SYSTEM_ADMIN);
        severityLevelValue();
        List<Account> accList = new List<Account>();
        Account accData1= new Account(Name = TEST_USER_ROLE+NUM);
        Account accData2= new Account(Name = TEST_USER_ROLE+NUM+1);
        accList.add(accData1);
        accList.add(accData2);
        insert accList;
        delete accList;
        Database.DeleteResult[] delRes = Database.delete(accList, false);            
                
        Test.startTest();
        System.runAs(runUser){
           APS_LogExceptionEventCls.logDmlResults(null, delRes, accList, TEST_APP, TEST_CLASS, TEST_METHOD, null);
        }
        Test.stopTest();
        
        List<ExceptionLog__c> excpData = [SELECT ClassName__c, Severity__c FROM ExceptionLog__c WHERE Application__c=:TEST_APP LIMIT 50000]; 
        System.assertEquals(excpData[0].ClassName__c, TEST_CLASS);
        Integer noOfExcep = [SELECT COUNT() FROM ExceptionLog__c WHERE Application__c=:TEST_APP LIMIT 50000];
        System.assertEquals(noOfExcep, 2);
    }
    
    /**
      * @description       This Test Method is to verify that ExceptionLog__c record is merged with an existing ExceptionLog__c record
                           in case of any program throwing an Exception due to Database.insert() operation.
      * @param             NA
      * @return            void
      * @throws            NA
      */
    private static testMethod void handledExceptionSaveMerge(){
        User runUser = APS_UTIL_TestMethods.runningUser(HN_ALIAS+NUM+4 , SYSTEM_ADMIN);
        severityLevelValue();
        List<Account> accList1 = new List<Account>();
        List<Account> accList2 = new List<Account>();
        
        Account accData1= new Account(Name = TEST_USER_ROLE+NUM );
        Account accData2= new Account();
        Account accData3= new Account(Name = TEST_USER_ROLE+NUM+1 );
        accList1.add(accData1);
        accList1.add(accData2);
        accList2.add(accData3);
        accList2.add(accData2);
        Database.SaveResult[] svRes1 = Database.insert(accList1, false);   
        Database.SaveResult[] svRes2 = Database.insert(accList2, false);                        
        Test.startTest();
        System.runAs(runUser){
           APS_LogExceptionEventCls.logDmlResults(svRes1, null, accList1, TEST_APP, TEST_CLASS, TEST_METHOD, null);
           APS_LogExceptionEventCls.logDmlResults(svRes2, null, accList2, TEST_APP, TEST_CLASS, TEST_METHOD, null);
        }
        Test.stopTest();
        
        ExceptionLog__c excpData = [SELECT NumberOfTimesOccured__c FROM ExceptionLog__c WHERE Application__c=:TEST_APP LIMIT 50000]; 
        System.assertEquals(excpData.NumberOfTimesOccured__c, 2);
    }

    /**
      * @description       This Test Method is to verify that ExceptionLog__c record is not logged when 
                           the Logging Level is below 'ERROR'.
      * @param             NA
      * @return            void
      * @throws            NA
      */
    private static testMethod void handledExceptionLoggingLevel(){
        User runUser = APS_UTIL_TestMethods.runningUser(HN_ALIAS+NUM+8 , SYSTEM_ADMIN);
        severityLevelValue();
        try{
            Account testData = new Account();
            insert(testData);           
        }
        catch(DMLException excp){        
            Test.startTest();
            System.runAs(runUser){
               APS_LogExceptionEventCls.logExceptionEvent(excp,TEST_CLASS, TEST_METHOD);
               APS_LogExceptionEventCls.logExceptionEvent(excp,TEST_CLASS, TEST_METHOD);
            }
            Test.stopTest();
        }
        Integer excpDataCount = [SELECT COUNT() FROM ExceptionLog__c WHERE Application__c=:TEST_APP LIMIT 50000]; 
        System.assertEquals(excpDataCount, 0);
    }
    
    /**
      * @description       This Test Method is to verify that ExceptionLog__c record is logged 
                           in case of any program throwing a Handled Exception due to webservice call.
      * @param             NA
      * @return            void
      * @throws            NA
      */
    private static testMethod void logretryException(){
         User runUser = APS_UTIL_TestMethods.runningUser(HN_ALIAS+NUM+9 , SYSTEM_ADMIN);
         severityLevelValue();
         try{
             Account testData = new Account();
             insert(testData);           
         }
         catch(Exception excp){        
             Test.startTest();
             System.runAs(runUser){
                APS_LogExceptionEventCls.reTryException(excp,TEST_CLASS, TEST_METHOD);
             }
             Test.stopTest();
         }
         //ExceptionLog__c excpData = [SELECT ClassName__c, Severity__c FROM ExceptionLog__c WHERE Application__c=:TEST_APP]; 
         //System.assertEquals(excpData.ClassName__c, TEST_CLASS);
    }
    
        /**
      * @description       This Test Method is to verify that ExceptionLog__c record is logged 
                           in case of any program throwing a Handled Exception. 
      * @param             NA
      * @return            void
      * @throws            NA
      */
    private static testMethod void handledExceptionMerge2(){
        User runUser = APS_UTIL_TestMethods.runningUser(HN_ALIAS+NUM , SYSTEM_ADMIN);
        severityLevelValue();
         List<Integer> li = new List<Integer>();
        try{
           
            li.add(15);
            Integer i1 = li[0]; 
            Integer i2 = li[1];           
        }
        catch(Exception excp){        
            Test.startTest();
            System.runAs(runUser){
               APS_UTIL_LoggingService.logHandledException(excp, TEST_ORG_ID, TEST_APP, TEST_CLASS, TEST_METHOD, null, LoggingLevel.ERROR);
               ExceptionLog__c excpData = [SELECT Application__c,ContextUser__c,ExceptionCode__c,ExceptionDescription__c,ExceptionDetails__c,ExceptionType__c,isHandled__c,MethodName__c,OrgId__c,ClassName__c, Severity__c FROM ExceptionLog__c WHERE ClassName__c=:TEST_CLASS LIMIT 50000]; 
              // system.debug('@@@ Exception Data-->'+excpData);
               APS_LogExceptionEventCls.logExceptionEvent(excp,TEST_CLASS, TEST_METHOD);
            }
            Test.stopTest();
        }
        //ExceptionLog__c excpData = [SELECT ClassName__c, Severity__c FROM ExceptionLog__c WHERE ClassName__c=:TEST_CLASS LIMIT 1]; 
        //System.assertEquals(excpData.ClassName__c, TEST_CLASS);
    }
}