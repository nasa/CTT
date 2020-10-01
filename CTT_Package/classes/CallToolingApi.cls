/*
-----------------------------------------------------------------------------------------------------------------------------------
Author      : Ravindra Talluri
Class       : CallToolingApi
Description : Creates triggers and helper Classes.
Created Date: 10/18/2017
-----------------------------------------------------------------------------------------------------------------------------------
*/
global with sharing class CallToolingApi{
    /*
-----------------------------------------------------------------------------------------------------------------------------------
Method     : createTrigger
Description:
-----------------------------------------------------------------------------------------------------------------------------------
*/
    webservice static String createTrigger(String triggerName, String sessionId){
        String returnMsg = TriggerFrameworkConstants.NULLVALUE;
        try{
            ApexTrigger apexTriggerObj = [SELECT Id, Name FROM ApexTrigger WHERE Name=:triggerName.removeEnd(TriggerFrameworkConstants.UnderscoreUnderscoreC)+TriggerFrameworkConstants.UnderscoreTrigger limit 1];
            returnMsg = TriggerFrameworkConstants.TriggerAlreadyExisting;
        }catch(Exception e){
            createTriggerFuture(triggerName, sessionId);
            return TriggerFrameworkConstants.TriggerCreated;
        }
        return returnMsg;
    }
    /*
-----------------------------------------------------------------------------------------------------------------------------------
Method     : createClass
Description:
-----------------------------------------------------------------------------------------------------------------------------------
*/
    webservice static String createClass(String helperName, String sessionId){
        String returnMsg = TriggerFrameworkConstants.NULLVALUE;
        
        TriggerFramework_Extensibility_Enabled__mdt ext = [select Enabled__c from TriggerFramework_Extensibility_Enabled__mdt where MasterLabel='Override'];
        
        TriggerFrameworkConfig__mdt config = [select Object_Name__c,Trigger_Event__c from TriggerFrameworkConfig__mdt where DeveloperName=:helperName];
        
        String sObjectName = config.Object_Name__c;
        String sCoreClassName = config.Object_Name__c;
        boolean bMoreLength =false;
        if(sCoreClassName.indexOf('__c')>=0){
            sCoreClassName = sCoreClassName.substring(0,sCoreClassName.indexOf('__c'));
        }
        if(sCoreClassName.length()>19){
            bMoreLength= true;
        }    
        while(bMoreLength== true){
            if(sCoreClassName.lastIndexOf('_')>=0){
                sCoreClassName = sCoreClassName.substring(0, sCoreClassName.lastIndexOf('_'));
                if(sCoreClassName.length()<=19 || sCoreClassName.lastIndexOf('_') <=0){
                    bMoreLength= false;
                }
            }
        }
        if(sCoreClassName.length()>19){
            sCoreClassName = sCoreClassName.subString(0,24);
        }
        sCoreClassName = sCoreClassName.replaceAll('[^a-zA-Z0-9\\s+]', '');
        String coreClassName = sCoreClassName+config.Trigger_Event__c+'HelperCore';
        
        List<String> helperClasses = new List<String>();
        List<ApexClass> apexClasses = new List<ApexClass>();
        String retMsg = '';
        try{
            if(ext.Enabled__c){
                helperClasses.add(coreClassName);
            }
            helperClasses.add(helperName);
            apexClasses = [SELECT Id, Name FROM ApexClass WHERE Name IN:helperClasses];
            if(!apexClasses.isEmpty()){
                returnMsg = TriggerFrameworkConstants.HelperAlreadyExisting+':'+apexClasses[0].Name;
            }else{
                createClassFuture(helperName, sessionId,coreClassName,ext.Enabled__c, sObjectName);
                returnMsg = TriggerFrameworkConstants.HelperCreated;
            }
        }catch(Exception e){
            returnMsg = e.getMessage();
        }
        return returnMsg;
    }
    /*
-----------------------------------------------------------------------------------------------------------------------------------
Method     : createTriggerFuture
Description:
-----------------------------------------------------------------------------------------------------------------------------------
*/
    @future (callout=true)
    public static void createTriggerFuture(String triggerName, String sessionId){
        try{
            String triggerjson = '{ "Name" : "'+triggerName.removeEnd('__c')+'_Trigger", "TableEnumOrId" : "'+triggerName+'", "Body" : "trigger '+triggerName.removeEnd('__c')+'_Trigger on '+triggerName+' (before insert, before update, before delete, after insert, after update, after delete, after undelete) {TriggerFramework.handle();}" }';
            
            Httprequest triggerreq = new HttpRequest();
            triggerreq.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm() +TriggerFrameworkConstants.Endpoint_Trigger);
            triggerreq.setMethod(TriggerFrameworkConstants.POST);
            triggerreq.setHeader(TriggerFrameworkConstants.Content_Type, TriggerFrameworkConstants.application_json);
            triggerreq.setHeader(TriggerFrameworkConstants.Authorization, TriggerFrameworkConstants.OAuth + sessionId);
            triggerreq.setBody(triggerjson);
            Http triggerhttpReq = new Http();
            HttpResponse triggerres = triggerhttpReq.send(triggerreq);
            
        }catch(Exception e){
            e.getMessage();
        }
    }
    /*
-----------------------------------------------------------------------------------------------------------------------------------
Method     : createClassFuture
Description:
-----------------------------------------------------------------------------------------------------------------------------------
*/
    @future (callout=true)
    public static void createClassFuture(String helperName, String sessionId,String coreClass, Boolean isOverrideEnabled, String sObjectName){
        try{
            String classjsonCore = '{ "Name" : "'+coreClass+'", "Body" : "public virtual class '+coreClass+' implements TriggerFramework.IHandler{public void execute(TriggerFramework.Context context) {List<'+sObjectName+'> newList = (List<'+sObjectName+'>)context.newList;Map<Id, '+sObjectName+'> newMap = (Map<Id, '+sObjectName+'>)context.newMap;}}" }';  
            String classjsonwithOutOveride = '{ "Name" : "'+helperName+'", "Body" : "public class '+helperName+' implements TriggerFramework.IHandler{public void execute(TriggerFramework.Context context) {List<'+sObjectName+'> newList = (List<'+sObjectName+'>) context.newList;Map<Id, '+sObjectName+'> newMap = (Map<Id, '+sObjectName+'>) context.newMap;}}" }'; 
            String classjsonwithOverride = '{ "Name" : "'+helperName+'", "Body" : "public class '+helperName+' extends '+coreClass+' {public static void executeHelper(TriggerFramework.Context context) {List<'+sObjectName+'> newList = (List<'+sObjectName+'>) context.newList;Map<Id, '+sObjectName+'> newMap = (Map<Id, '+sObjectName+'>) context.newMap;}}" }'; 
            system.debug('isOverrideEnabled -- '+isOverrideEnabled);
            system.debug('classjsonCore -- '+classjsonCore);
            system.debug('classjsonwithOutOveride -- '+classjsonwithOutOveride);
            system.debug('classjsonwithOverride -- '+classjsonwithOverride);
            
            if(isOverrideEnabled){
                HttpRequest coreClassReq = getHttpRequest(classjsonCore,sessionId);
                System.debug('coreClassReq -- '+coreClassReq);
                Http coreClassRes = new Http();
                HttpResponse coreRes = coreClassRes.send(coreClassReq); 
                if(coreRes.getStatusCode() == 200 || coreRes.getStatusCode() == 201){
                    HttpRequest childClassReq = getHttpRequest(classjsonwithOverride,sessionId);
                    Http childClassRes = new Http();
                    HttpResponse childRes = childClassRes.send(childClassReq); 
                }
            }else{
                HttpRequest classreq = getHttpRequest(classjsonwithOutOveride,sessionId);
                Http classhttpRes = new Http();
                HttpResponse classRes = classhttpRes.send(classreq);
            }
        }catch(Exception e){
            system.debug('Error in createClassFuture -- '+e);
            e.getMessage();
        }
    }
    
    private static HttpRequest getHttpRequest(String classjson,String sessionId){
        HttpRequest req = new HttpRequest();
        System.debug('url -- '+URL.getSalesforceBaseUrl().toExternalForm() +TriggerFrameworkConstants.Endpoint_Class);
        System.debug('session -- '+TriggerFrameworkConstants.OAuth  + sessionId);
        System.debug('contenttype -- '+TriggerFrameworkConstants.Content_Type);
        System.debug('json -- '+TriggerFrameworkConstants.application_json);
        
        req.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm() +TriggerFrameworkConstants.Endpoint_Class);
        req.setMethod(TriggerFrameworkConstants.POST);
        req.setHeader(TriggerFrameworkConstants.Content_Type, TriggerFrameworkConstants.application_json);
        req.setHeader(TriggerFrameworkConstants.Authorization, TriggerFrameworkConstants.OAuth  + sessionId);
        req.setBody(classjson);
        return req;
    }
    
}