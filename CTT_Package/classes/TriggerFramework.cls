/*
-----------------------------------------------------------------------------------------------------------------------------------
Author     : Ravindra Talluri
Class      : TriggerFramework 
Description: It includes handle, getObjectName and configuration methods
-----------------------------------------------------------------------------------------------------------------------------------
*/
public with sharing class TriggerFramework {
    
    /****************************/
    public Enum Event { BeforeInsert, BeforeUpdate, BeforeDelete, AfterInsert, AfterUpdate, AfterDelete, AfterUndelete }
    
    public interface IHandler {
        void execute(Context context);
    }
    
    private static List<TriggerFrameworkProfileConfig__mdt> configurations = new List<TriggerFrameworkProfileConfig__mdt>();
    
    /* Used to track the object name and the level */
    private static Map<String, Integer> recursionDepth = new Map<String, Integer>();
    
    private static Map<String, Savepoint> savePoints = new Map<String, Savepoint>();
    
    /* Use to cache if conventionBasedHandlers are enabled */
    private static Map<String, Boolean> conventionBasedHandlerEnabled = new Map<String, Boolean>();
    
    //public static Set<String> functionNames = new Set<String>();
    /*
-----------------------------------------------------------------------------------------------------------------------------------
Method: getSObjectTypeName
Description:
-----------------------------------------------------------------------------------------------------------------------------------
*/    
    private static String getSObjectTypeName(List<SObject> oldList, List<SObject> newList) {
        String sObjectTypeName = TriggerFrameworkConstants.NULLVALUE;
        if(oldList != null && oldList.getSObjectType() != null) {
            sObjectTypeName = oldList.getSObjectType().getDescribe().getName();
        }
        if(newList != null && newList.getSObjectType() != null) {
            sObjectTypeName = newList.getSObjectType().getDescribe().getName();
        }
        return sObjectTypeName;
    }
    /*
-----------------------------------------------------------------------------------------------------------------------------------
Method: getEvent
Description:
-----------------------------------------------------------------------------------------------------------------------------------
*/     
    private static Event getEvent(Boolean isBefore, Boolean isAfter, Boolean isDelete, Boolean isInsert, Boolean isUpdate, Boolean isUndelete) {
        if (isBefore && isInsert) return Event.BeforeInsert;
        else if (isBefore && isUpdate) return Event.BeforeUpdate;
        else if (isBefore && isDelete) return Event.BeforeDelete;
        else if (isAfter && isInsert) return Event.AfterInsert;
        else if (isAfter && isUpdate) return Event.AfterUpdate;
        else if (isAfter && isDelete) return Event.AfterDelete;
        else if (isAfter && isUndelete) return Event.AfterUndelete;
        throw new TriggerException(TriggerFrameworkConstants.Invalid_Combintn_Of_Triggr_Paramtrs);
    }
    /*
-----------------------------------------------------------------------------------------------------------------------------------
Class: Context
Description:
-----------------------------------------------------------------------------------------------------------------------------------
*/    
    public with sharing class Context {
        public Event event { get; private set;}
        public List<SObject> oldList { get; private set; }
        public List<SObject> newList { get; private set; }
        public Map<Id, SObject> oldMap { get; private set; }
        public Map<Id, SObject> newMap { get; private set; }
        public String triggerObject { get; private set; }
        public Boolean isExecuting { get; private set; }
        public String recursionKey { get; private set; }
        public Boolean isInsert { get; private set; }
        public Boolean isUpdate { get; private set; }
        public Boolean isDelete { get; private set; }
        public Boolean isUnDelete { get; private set; }
        public Boolean isAfter { get; private set; }
        public Boolean isBefore { get; private set; }     
        /*
-----------------------------------------------------------------------------------------------------------------------------------
Method: Context
Description:
-----------------------------------------------------------------------------------------------------------------------------------
*/        
        public Context(List<SObject> oldList, List<SObject> newList, Map<Id, SObject> oldMap, Map<Id, SObject> newMap,
                       Boolean isBefore, Boolean isAfter, Boolean isDelete, Boolean isInsert, Boolean isUpdate, Boolean isUndelete,
                       Boolean isExecuting) {
                           this.event = getEvent(isBefore, isAfter, isDelete, isInsert, isUpdate, isUnDelete);
                           this.oldList = oldList;
                           this.newList = newList;
                           this.oldMap = oldMap;
                           this.newMap = newMap;
                           this.triggerObject = getSObjectTypeName(oldList, newList);
                           this.isExecuting = isExecuting;
                           this.recursionKey = this.triggerObject + TriggerFrameworkConstants.Underscore + this.event;
                           this.isInsert = isInsert;
                           this.isUpdate = isUpdate;
                           this.isDelete = isDelete;
                           this.isUnDelete = isUndelete;
                           this.isAfter = isAfter;
                           this.isBefore = isBefore;
                       }
        /*
-----------------------------------------------------------------------------------------------------------------------------------
Method: getRecursionDepth
Description:
-----------------------------------------------------------------------------------------------------------------------------------
*/        
        public Integer getRecursionDepth() {
            try{
                if (!recursionDepth.containsKey(this.recursionKey)) 
                    throw new TriggerException(TriggerFrameworkConstants.Enter_Not_Called);
                
            }catch(DMLException e){
                e.getMessage();
            }
            return recursionDepth.get(this.recursionKey);
        }
        /*
-----------------------------------------------------------------------------------------------------------------------------------
Method: enterObject
Description:
-----------------------------------------------------------------------------------------------------------------------------------
*/        
        public void enterObject() {
            try{
                if (!recursionDepth.containsKey(this.recursionKey)) {
                    recursionDepth.put(this.recursionKey, 0);
                }
                recursionDepth.put(this.recursionKey, recursionDepth.get(this.recursionKey) + 1);
            }catch(Exception e){
                e.getMessage();
            }
        }
        /*
-----------------------------------------------------------------------------------------------------------------------------------
Method: exitObject
Description:
-----------------------------------------------------------------------------------------------------------------------------------
*/        
        public void exitObject() {
            try{
                if (!recursionDepth.containsKey(this.recursionKey)) {
                    throw new TriggerException(TriggerFrameworkConstants.Exit_Called_Without_Enter);
                }
                Integer i = recursionDepth.get(this.recursionKey) - 1;
                if (i < 0) {
                    throw new TriggerException(TriggerFrameworkConstants.Enter_Exit_Mismatch);
                }
                recursionDepth.put(this.recursionKey, i);
            }catch(Exception e){
                e.getMessage();
            }
        }
        /*
-----------------------------------------------------------------------------------------------------------------------------------
Method: beginTrans
Description:
-----------------------------------------------------------------------------------------------------------------------------------
*/        
        public void beginTrans() {
            try{
                if (!savePoints.containsKey(this.triggerObject)) {
                    Savepoint sp = Database.setSavepoint();
                    savePoints.put(this.triggerObject, sp);
                }
            }catch(Exception e){
                e.getMessage();
            }
        }
        /*
-----------------------------------------------------------------------------------------------------------------------------------
Method: rollbackTrans
Description:
-----------------------------------------------------------------------------------------------------------------------------------
*/        
        public void rollbackTrans() {
            try{
                if (!savePoints.containsKey(this.triggerObject)) {
                    throw new TriggerException(TriggerFrameworkConstants.No_beginTrans_called_for + this.triggerObject);
                } else {
                    Savepoint sp = savePoints.get(this.triggerObject);
                    Database.rollback(sp);
                    savePoints.remove(this.triggerObject);
                }
            }catch(Exception e){
                e.getMessage();
            }
        }
        
    }
    /*
-----------------------------------------------------------------------------------------------------------------------------------
Class      : TriggerException 
Description: It includes handle, getObjectName and configuration methods
-----------------------------------------------------------------------------------------------------------------------------------
*/    
    public with sharing class TriggerException extends Exception {}
    /*
-----------------------------------------------------------------------------------------------------------------------------------
Method: getRecordsForConfigFieldsUpdate
Description:
-----------------------------------------------------------------------------------------------------------------------------------
*/
    private static Boolean matchesConfiguration(TriggerFramework.Context context, TriggerFrameworkProfileConfig__mdt config) {
        if (config.config__r.Object_Name__c == context.triggerObject && config.config__r.Trigger_Event__c == context.event.name()){
            return true;
        }
        return false;
    }
    /*
-----------------------------------------------------------------------------------------------------------------------------------
Method: getRecordsForConfigFieldsUpdate
Description:
-----------------------------------------------------------------------------------------------------------------------------------
*/    
    private static Boolean getRecordsForConfigFieldsUpdate(TriggerFramework.Context context, TriggerFrameworkProfileConfig__mdt config, List<Sobject> oldList, List<Sobject> newList) {
        /* Get the comma list of configured fields */
        /* No configured fields means any field changes calls the handler */
        Set<String> configuredFields = new Set<String>();
        if (!String.isBlank(config.Config__r.Fields__c)) {
            configuredFields.addAll(config.Config__r.Fields__c.split(TriggerFrameworkConstants.SplitBy));
        } else {
            return false;
        }
        /* Peform field by field comparison */
        for (SObject source : context.oldList ) {
            SObject destination = context.newMap.get(source.Id);
            for (String nextCheckField : configuredFields) {
                if (String.valueof(source.get(nextCheckField)) != String.valueof(destination.get(nextCheckField)) ) {
                    oldList.add(source);
                    newList.add(destination);
                }
            }
        }
        return true;
    }
    /*
-----------------------------------------------------------------------------------------------------------------------------------
Method: validConfig
Description:
-----------------------------------------------------------------------------------------------------------------------------------
*/    
    private static Boolean validConfig(Context triggerContext, Integer maxReentry) {
        /* Allow to re-enter */
        Integer recursionDepthValue = triggerContext.getRecursionDepth();
        if (recursionDepthValue <= maxReentry) {
            return true;
        }
        return false;
    }
     /*
-----------------------------------------------------------------------------------------------------------------------------------
Author : Nagendra Chinchinada
Method: sortProfileConfigs
Description: method to sort configurations ORDER BY Config__r.HandlerClass_ExecutionOrder__c, 
            since ORDER BY in SOQL works only with non-relationship fields
-----------------------------------------------------------------------------------------------------------------------------------
*/    
    private static List<TriggerFrameworkProfileConfig__mdt> sortProfileConfigs(List<TriggerFrameworkProfileConfig__mdt> configurations){
        Map<Integer, TriggerFrameworkProfileConfig__mdt> profileConfigMap = new Map<Integer, TriggerFrameworkProfileConfig__mdt>();
        List<Integer> excecutionOrder = new List<Integer>();
        List<TriggerFrameworkProfileConfig__mdt> configurationsSorted = new List<TriggerFrameworkProfileConfig__mdt>();
        for(TriggerFrameworkProfileConfig__mdt config : configurations){
            profileConfigMap.put(Integer.valueOf(config.Config__r.HandlerClass_ExecutionOrder__c), config);
        }
        excecutionOrder.addAll(profileConfigMap.keyset());
        excecutionOrder.sort();//Default ASC        
              
        for(Integer order : excecutionOrder){
           configurationsSorted.add(profileConfigMap.get(order)); 
        }
        return configurationsSorted;        
    }
    /*
-----------------------------------------------------------------------------------------------------------------------------------
Method: handle
Description:
-----------------------------------------------------------------------------------------------------------------------------------
*/    
    public static void handle() {
        Context context = new Context(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap,
                                      Trigger.isBefore, Trigger.isAfter, Trigger.isDelete, Trigger.isInsert, Trigger.isUpdate, Trigger.isUnDelete,
                                      Trigger.isExecuting);
        try{
            context.enterObject();
            //if (configurations.isEmpty()) {
            System.debug('context.triggerObject -- '+context.triggerObject);
                configurations = [SELECT Config__r.DeveloperName,
                                  Config__r.Enabled__c, Config__r.Fields__c, 
                                  Config__r.Max_ReEntry__c, Config__r.Object_Name__c, 
                                  Config__r.Trigger_Event__c, Config__r.Use_New_Transaction__c,
                                  Config__r.HandlerClass_ExecutionOrder__c
                                  FROM TriggerFrameworkProfileConfig__mdt 
                                  WHERE Profile__r.Profile_Id__c=:UserInfo.getProfileId() AND Profile__r.Active__c=true and Config__r.Object_Name__c=:context.triggerObject
                                  //ORDER BY Config__r.HandlerClass_ExecutionOrder__c ASC  //You can use ORDER BY only with non-relationship fields
                                  LIMIT 50000];               
            //}
            
            //if(!configurations.isEmpty()){
                //configurations = sortProfileConfigs(configurations);// Sort list ORDER BY Config__r.HandlerClass_ExecutionOrder__c
            //}
            if (!configurations.isEmpty()){
                
                for(TriggerFrameworkProfileConfig__mdt config : configurations) {
                    try {
                        if (config.Config__r.Enabled__c) {
                            //functionNames.addAll(config.Function_Name__c.split(','));
                            if (matchesConfiguration(context, config)) {
                                if (validConfig(context, (Integer)config.Config__r.Max_ReEntry__c)){
                                    if (config.Config__r.Use_New_Transaction__c) {
                                        context.beginTrans();
                                    }
                                    Type handlerType = Type.forName(config.Config__r.DeveloperName);
                                    TriggerFramework.IHandler handler = (TriggerFramework.IHandler)handlerType.newInstance();
                                    if(context.isUpdate){
                                        List<SObject> oldList = new List<SObject>();
                                        List<SObject> newList = new List<SObject>();
                                        if (getRecordsForConfigFieldsUpdate(context, config, oldList, newList)) {
                                            if(!oldList.isEmpty()){
                                                /* Create a new context using the replaced maps and lists on the config */
                                                handler.execute(new Context(oldList, newList, Trigger.oldMap, Trigger.newMap,
                                                                            Trigger.isBefore, Trigger.isAfter, Trigger.isDelete, Trigger.isInsert, Trigger.isUpdate, Trigger.isUnDelete,
                                                                            Trigger.isExecuting));
                                            }else{
                                                continue;
                                            }
                                        }else{
                                            handler.execute(context);
                                        }
                                    }else{
                                        handler.execute(context);
                                    }
                                }
                            }
                        }
                    }catch (Exception ex) {
                        if (config.Config__r.Use_New_Transaction__c) {
                            context.rollbackTrans();
                        } else {
                            throw ex;
                        }
                    }
                }
            }
        }catch (Exception e) {
            e.getMessage();
            
        }finally {
            context.exitObject();
        }
    }
}