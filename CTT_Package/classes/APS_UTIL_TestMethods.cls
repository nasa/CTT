/**
  * @author        Urmi Chatterjee
  * @date          30/10/2013
  * @description   UTIL Class for creation of common Data used in Test Classes.
  */
  
public with sharing class APS_UTIL_TestMethods{
    private static final string RUNNINGUSER='runningUser';
    private static final string CLASSNAME='APS_UTIL_TestMethods';
    /**
      * @description       Method for defining User object record to be created for use in Test Class. 
      * @param             aliasId the Alias Id of the User record is to be created
      * @param             profileName the profile for which the User record is to be created
      * @return            User
      * @throws            NA
      */
    public static User runningUser(String aliasId, String profileName){
        try{
        Id profId = [SELECT Id FROM Profile WHERE Name=: profileName LIMIT 50000].Id;
        User userData = new User(FirstName=aliasId, LastName=aliasId, Alias=aliasId, IsActive=True, Email=aliasId+'@test.com',
                                 ProfileId=profId, Username=aliasId+'@test.com', EmailEncodingKey='UTF-8', CommunityNickname='Test',
                                 LanguageLocaleKey='en_US', LocaleSidKey='en_US', TimeZoneSidKey='GMT');
        return userData;
        }
        Catch(Exception e){    
            APS_LogExceptionEventCls.logExceptionEvent(e,CLASSNAME,RUNNINGUSER);
            return null;
                }
    }
    
    /**
      * @description       Method for setting the Custom Setting Value to display fixed records on a Visualforce page
                           for use in Test Class.
      * @param             custName the Custom Setting name
      * @param             num the number of records value
      * @return            void
      * @throws            NA
      */
  /*  public static void createCustomSetting(String custName, Integer num){
        PaginationRecords__c noOfRecs = new PaginationRecords__c(Name=custName, NumberofRecords__c=num);
        insert noOfRecs;
    }*/
}