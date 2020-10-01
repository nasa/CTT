/*
************************************************************************************************************************************
@Class Name: APS_UTIL_TestMethods_Test
@description : 
@author:
@date :  
@modificationLog : 
*************************************************************************************************************************************
*/
@isTest(seeAllData=false) private with sharing class APS_UTIL_TestMethods_Test {
    Private static User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
    /*
************************************************************************************************************************************
@Method Name: utilMethodsTest
@description : 
@author:
@date :  
@params:
@modificationLog : 
*************************************************************************************************************************************
*/
    @isTest static void utilMethodsTest()
    {
        System.runAs(thisUser){
            test.startTest();
            APS_UTIL_TestMethods.runningUser(null,null);
            APS_UTIL_TestMethods.runningUser('test','Patient Services Nurse');
            test.stopTest();
        }
    }
}