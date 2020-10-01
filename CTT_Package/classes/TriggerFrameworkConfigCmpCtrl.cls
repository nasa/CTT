/*
    -----------------------------------------------------------------------------------------------------------------------------------
    Author: Ravindra Talluri 
    Description: To create,Save,Delete Configurations and to check the profile access.
    Created Date: 10/19/2017
    -----------------------------------------------------------------------------------------------------------------------------------
*/
public with sharing class TriggerFrameworkConfigCmpCtrl { 
    private static String deploymentUrl = '/changemgmt/monitorDeploymentsDetails.apexp?asyncId=';   
/*
    -----------------------------------------------------------------------------------------------------------------------------------
    Method: getConfigData
    Description:
    -----------------------------------------------------------------------------------------------------------------------------------
*/
    @AuraEnabled
    public static Map<String, Object> getConfigData(String profileId) {
        Map<String, Object> returnMap = new Map<String, Object>();
        try{
            if(profileId == TriggerFrameworkConstants.NULLVALUE){
                List<Profile> profilesList = [SELECT Id, Name From Profile ORDER BY Name LIMIT 1000];
                returnMap.put(TriggerFrameworkConstants.profileList, profilesList);
                returnMap.put(TriggerFrameworkConstants.configData, TriggerFrameworkConfigCmpCtrl.getCofigs(profilesList[0].Id));
            }else{
                returnMap.put(TriggerFrameworkConstants.configData, TriggerFrameworkConfigCmpCtrl.getCofigs(profileId));
            }
            Set<String> activeProfileIds = new Set<String>();
            //TO DO - Add Active in query filter
            for(TriggerFrameworkProfile__mdt tfpc : [SELECT Id,Profile_Id__c, Active__c FROM TriggerFrameworkProfile__mdt LIMIT 1000]){
                if(tfpc.Active__c){
                    activeProfileIds.add(tfpc.Profile_Id__c);
                }
            }
            returnMap.put(TriggerFrameworkConstants.ActiveProfileIds, activeProfileIds);
        }catch(Exception e){
            e.getMessage();
        }
        return returnMap;
    }
    
/*
    -----------------------------------------------------------------------------------------------------------------------------------
    Method: getCofigs
    Description:
    -----------------------------------------------------------------------------------------------------------------------------------
*/
    public static List<TriggerFrameworkConfig__mdt> getCofigs(String profileId){
        List<TriggerFrameworkConfig__mdt> configsList = new List<TriggerFrameworkConfig__mdt>();
        try{
            configsList = [SELECT Id,DeveloperName,Enabled__c,Fields__c,Max_ReEntry__c,Object_Name__c,
                           Trigger_Event__c,Use_New_Transaction__c,Temp__c,HandlerClass_ExecutionOrder__c
                           FROM TriggerFrameworkConfig__mdt WHERE Disabled__c=false
                           ORDER BY Object_Name__c, HandlerClass_ExecutionOrder__c
                        LIMIT 50000];
            Set<String> configIdSet = new Set<String>();
           List<TriggerFrameworkProfileConfig__mdt> tfpcList = [SELECT Id,Config__c FROM TriggerFrameworkProfileConfig__mdt 
                 WHERE Profile__r.Profile_Id__c=:profileId AND Disabled__c=false LIMIT 1000];
                for(TriggerFrameworkProfileConfig__mdt tfpc : tfpcList){
                configIdSet.add(tfpc.Config__c);
            }
            for(TriggerFrameworkConfig__mdt tfc : configsList){
                if(!configIdSet.isEmpty()){
                    if(configIdSet.contains(tfc.Id)){
                        tfc.Temp__c = true;
                    }
                } 
            }
        }catch(Exception e){
            e.getMessage();
        }
        return configsList;
    }
    
/*
    -----------------------------------------------------------------------------------------------------------------------------------
    Method: saveProfileConfigData
    Description:
    -----------------------------------------------------------------------------------------------------------------------------------
*/
    @AuraEnabled
    public static Map<String, Object> saveProfileConfigData(List<TriggerFrameworkConfig__mdt> configsList, String profileId) {
        Map<String, Object> responseMap = new Map<String, Object>();
        String jobId = '';
        List<TriggerFrameworkProfileConfig__mdt> tfpcInsertList = new List<TriggerFrameworkProfileConfig__mdt>();
        List<String> deleteConfigList = new List<String>();
        try{
            Set<String> configIdSet = new Set<String>();
            List<TriggerFrameworkProfileConfig__mdt> tfpcList = [SELECT Id,Profile__c, Config__c FROM TriggerFrameworkProfileConfig__mdt 
            WHERE Profile__r.Profile_Id__c=:profileId LIMIT 1000];
            for(TriggerFrameworkProfileConfig__mdt tfpc : tfpcList){
                configIdSet.add(tfpc.Config__c);
            }
            TriggerFrameworkProfile__mdt profileRecord = new TriggerFrameworkProfile__mdt();
            try{
                profileRecord = [SELECT Id,DeveloperName,Profile_Id__c FROM TriggerFrameworkProfile__mdt WHERE Profile_Id__c=:profileId LIMIT 1];
            }catch(Exception e){
                String profileName = [SELECT Id, Name FROM Profile WHERE Id=:profileId LIMIT 1].Name;
                profileRecord = new TriggerFrameworkProfile__mdt(DeveloperName =profileName, Profile_Id__c=profileId);
                //TODO - Done
                jobId = TriggerFrameworkUpsertMDT.upsertProfile(profileRecord);
            }
            for(TriggerFrameworkConfig__mdt tfc : configsList){
                if(tfc.Temp__c){
                    //if(!configIdSet.contains(tfc.Id)){
                        tfpcInsertList.add(new TriggerFrameworkProfileConfig__mdt(Developername=profileRecord.DeveloperName+'#'+tfc.DeveloperName,
                        Profile__c=profileRecord.Id, Config__c=tfc.Id,Disabled__c=false));
                    //}                    
                }else{
                    if(configIdSet.contains(tfc.Id)){
                        deleteConfigList.add(tfc.Id);
                    }
                }
            }
            //TO DO - Done
            if(!tfpcInsertList.isEmpty())
                jobId = TriggerFrameworkUpsertMDT.upsertProfileConfig(tfpcInsertList);
            //Database.Insert(tfpcInsertList,true);
            List<TriggerFrameworkProfileConfig__mdt> tfpcDeleteList = [SELECT Id,DeveloperName,Profile__c,Config__c, Disabled__c
             FROM TriggerFrameworkProfileConfig__mdt WHERE Profile__r.Profile_Id__C=: profileId AND Config__c=:deleteConfigList LIMIT 1000];
            //TO DO - Done
            
            for(TriggerFrameworkProfileConfig__mdt tfpcDeleteRec : tfpcDeleteList){
                tfpcDeleteRec.Disabled__c = True;// As we can't delete Metadata types, we make them to Disabled.
            }
             if(!tfpcDeleteList.isEmpty())
                TriggerFrameworkUpsertMDT.disableProfileConfig(tfpcDeleteList);
            //Database.Delete(tfpcDeleteList,true);
            responseMap.put(TriggerFrameworkConstants.State,TriggerFrameworkConstants.Success);
            responseMap.put(TriggerFrameworkConstants.Message, TriggerFrameworkConstants.Config_Binded_To_Profile+'. Job id is :'+deploymentUrl+jobId);
        }catch(Exception e){
            responseMap.put(TriggerFrameworkConstants.State,TriggerFrameworkConstants.Error);
            responseMap.put(TriggerFrameworkConstants.Message, e.getMessage());
        }
        return responseMap;
    }
    
/*
    -----------------------------------------------------------------------------------------------------------------------------------
    Method: createConfig
    Description:
    -----------------------------------------------------------------------------------------------------------------------------------
*/
    @AuraEnabled
    public static Map<String, Object> createConfig(String newConfigDataJson, String selectedProfileId) {
        String jobId = '';
        Map<String, Object> returnMap = new Map<String, Object>();
        TriggerFrameworkConfig__mdt newConfigData = (TriggerFrameworkConfig__mdt) JSON.deserialize(newConfigDataJson, TriggerFrameworkConfig__mdt.class);
        try{
            //TO DO - Done
            jobId = TriggerFrameworkUpsertMDT.upsertConfig(new List<TriggerFrameworkConfig__mdt>{newConfigData});
            returnMap = TriggerFrameworkConfigCmpCtrl.getConfigData(selectedProfileId);
            returnMap.put(TriggerFrameworkConstants.State,TriggerFrameworkConstants.Success);
            returnMap.put(TriggerFrameworkConstants.Message,TriggerFrameworkConstants.Config_Created_Successfully+'. Job id is :'+deploymentUrl+jobId);
        }catch(Exception e){
            returnMap.put(TriggerFrameworkConstants.State,TriggerFrameworkConstants.Error);
            returnMap.put(TriggerFrameworkConstants.Message, e.getMessage());
        }
        return returnMap;
    }
    
/*
    -----------------------------------------------------------------------------------------------------------------------------------
    Method: classOrTrigger
    Description:
    -----------------------------------------------------------------------------------------------------------------------------------
*/
    @AuraEnabled
    public static Map<String, Object> classOrTrigger(String triggerOrHelperName, String componentType) {
        Map<String, Object> returnMap = new Map<String, Object>();
        try{
            System.debug('componentType -- '+componentType);
            if(componentType == TriggerFrameworkConstants.Triggr){
                returnMap.put(TriggerFrameworkConstants.Message, CallToolingApi.createTrigger(triggerOrHelperName, UserInfo.getSessionId()));
            }else if(componentType == TriggerFrameworkConstants.Helper){
                returnMap.put(TriggerFrameworkConstants.Message, CallToolingApi.createClass(triggerOrHelperName, UserInfo.getSessionId()));
            }
            returnMap.put(TriggerFrameworkConstants.State,TriggerFrameworkConstants.Success);
        }catch(Exception e){
            System.debug('Error in classOrTrigger -- '+e);
            returnMap.put(TriggerFrameworkConstants.State,TriggerFrameworkConstants.Error);
            returnMap.put(TriggerFrameworkConstants.Message,TriggerFrameworkConstants.Somethng_went_wrng_pls_try_again);
        }
        return returnMap;
    }
    
/*
    -----------------------------------------------------------------------------------------------------------------------------------
    Method: toggleProfileAcess
    Description:
    -----------------------------------------------------------------------------------------------------------------------------------
*/
    @AuraEnabled
    public static Map<String, Object> toggleProfileAcess(String selectedProfileId, Boolean accessType) {
        String jobId = '';
        Map<String, Object> returnMap = new Map<String, Object>();
        TriggerFrameworkProfile__mdt profileRecord = new TriggerFrameworkProfile__mdt();
        try{
            profileRecord = [SELECT Id, DeveloperName, Active__c, Profile_Id__c FROM TriggerFrameworkProfile__mdt WHERE Profile_Id__c=:selectedProfileId LIMIT 1];
            if(accessType){
                profileRecord.Active__c = true;
            }else{
                profileRecord.Active__c = false;
            }
            //TO DO - Done
           jobId = TriggerFrameworkUpsertMDT.upsertProfile(profileRecord);
            //Database.Update(profileRecord,true);
            returnMap.put(TriggerFrameworkConstants.State,TriggerFrameworkConstants.Success);
            returnMap.put(TriggerFrameworkConstants.Message, TriggerFrameworkConstants.Saved_Successfully+'. Job id is :'+deploymentUrl+jobId);
        }catch(Exception e){
            String profileName = [SELECT Id, Name FROM Profile WHERE Id=:selectedProfileId LIMIT 1].Name;
            profileRecord = new TriggerFrameworkProfile__mdt(DeveloperName=profileName, Profile_Id__c=selectedProfileId);
            try{
                //TO DO - Done
                jobId = TriggerFrameworkUpsertMDT.upsertProfile(profileRecord);
                returnMap.put(TriggerFrameworkConstants.State,TriggerFrameworkConstants.Success);
                returnMap.put(TriggerFrameworkConstants.Message, TriggerFrameworkConstants.Saved_Successfully+'. Job id is :'+deploymentUrl+jobId);
            }catch(Exception e2){
                returnMap.put(TriggerFrameworkConstants.State,TriggerFrameworkConstants.Error);
                returnMap.put(TriggerFrameworkConstants.Message, TriggerFrameworkConstants.Somethng_went_wrng_pls_try_again);
            }
        }
        return returnMap;
    }    
    
/*
    -----------------------------------------------------------------------------------------------------------------------------------
    Method: deleteConfigData
    Description:
    -----------------------------------------------------------------------------------------------------------------------------------
*/
    @AuraEnabled
    public static Map<String, Object> deleteConfigData(String recordId) {
        String jobId = '';
        Map<String, Object> responseMap = new Map<String, Object>();
        try{
            //TriggerFrameworkConfig__mdt configObj = new TriggerFrameworkConfig__mdt();
            TriggerFrameworkConfig__mdt configObj = [SELECT Id,DeveloperName,Trigger_Event__c FROM TriggerFrameworkConfig__mdt WHERE Id=:recordId LIMIT 1];
            //configObj.Id = recordId;
            //TO DO - Done
            configObj.Disabled__c = true;
            jobId = TriggerFrameworkUpsertMDT.disableConfig(new List<TriggerFrameworkConfig__mdt>{configObj});
            responseMap.put(TriggerFrameworkConstants.State,TriggerFrameworkConstants.Success);
            responseMap.put(TriggerFrameworkConstants.Message,TriggerFrameworkConstants.Config_Deleted+'. Job id is :'+deploymentUrl+jobId);
        }catch(Exception e){
            responseMap.put(TriggerFrameworkConstants.State,TriggerFrameworkConstants.Error);
            responseMap.put(TriggerFrameworkConstants.Message, e.getMessage());
        }
        return responseMap;
    } 
      
}