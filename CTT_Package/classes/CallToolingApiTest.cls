@isTest
global with sharing class CallToolingApiTest {
    
    public static testmethod void testMethod1() {
        CustomMetadataDAOTest.setMetadata(
            'SELECT Enabled__c FROM TriggerFramework_Extensibility_Enabled__mdt WHERE MasterLabel = \'Override\'',
            (List<TriggerFramework_Extensibility_Enabled__mdt>) JSON.deserialize( '[{"Enabled__c ":true}]', List<TriggerFramework_Extensibility_Enabled__mdt>.class )
        );
        CustomMetadataDAOTest.setMetadata(
            'select Object_Name__c,Trigger_Event__c from TriggerFrameworkConfig__mdt where DeveloperName= \'AccHelper\'',
            (List<TriggerFrameworkConfig__mdt>) JSON.deserialize( '[{"Object_Name__c":"Account","Trigger_Event__c":"AfterInsert"}]', List<TriggerFrameworkConfig__mdt>.class )
        );
        Test.setMock(HttpCalloutMock.class, new testRestCall());
        Test.startTest();
        TriggerFrameworkConfigCmpCtrl.classOrTrigger('triggerName', 'Trigger');
        TriggerFrameworkConfigCmpCtrl.classOrTrigger('handlerName', 'Helper');

        TriggerFrameworkConfigCmpCtrl.classOrTrigger('Account', 'Trigger');
        TriggerFrameworkConfigCmpCtrl.classOrTrigger('AccountInsTriggerHelper', 'Helper');
        Test.stopTest();
    }
    
    global class testRestCall implements HTTPCalloutMock{
        global HTTPResponse respond(HTTPRequest req){
            HttpResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/JSON');
            res.setBody('Response Body');
            res.setStatus('Success');
            res.setStatusCode(200);
            return res;
        }
    }
}