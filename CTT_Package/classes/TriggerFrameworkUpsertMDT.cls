/*
-----------------------------------------------------------------------------------------------------------------------------------
Author: Nagendra Chinchinada
Description: To create,update Custom Metata Data Types records
Created Date: 05/15/2019
-----------------------------------------------------------------------------------------------------------------------------------
*/
public with sharing class TriggerFrameworkUpsertMDT { 
    /*
-----------------------------------------------------------------------------------------------------------------------------------
Method: upsertMDT
Description: Method to create,update Custom Metata Data Types records
Parameters : mtdObjetAPIName - Object API Name
cmdRecords - List of meta data records of type mtdObjetAPIName in the form of CustomMetadataType wrapper class
-----------------------------------------------------------------------------------------------------------------------------------
*/
    public static string upsertMDT(String mtdObjetAPIName, List<CustomMetadataType> cmdRecords){
        String jobId='';
        List<Metadata.CustomMetadata> customMetadataList =  new List<Metadata.CustomMetadata>();        
        try{
            for (CustomMetadataType metadataRecord : cmdRecords) {
                Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
                String recordDevName = metadataRecord.label.replaceAll(' ', '_'); 
                
                customMetadata.fullName = mtdObjetAPIName+'.' + recordDevName;
                customMetadata.label = metadataRecord.label;
                
                // Add all the field values
                Metadata.CustomMetadataValue customField;
                for(MDTFieldValue fieldValue : metadataRecord.fieldValues) {
                    system.debug('fieldValue: '+fieldValue);
                    customField = new Metadata.CustomMetadataValue();
                    customField.field = fieldValue.field;
                    customField.value = fieldValue.value;
                    customMetadata.values.add(customField);
                }
                customMetadataList.add(customMetadata);            
            }  
            
            
            // Setup deploy callback, MyDeployCallback implements the Metadata.DeployCallback interface 
            TriggerFrameworkMDTCallback callback = new TriggerFrameworkMDTCallback();
            
            //Deploy metadata 
            //If there are morethan 1 records to deploy, will be deployed one by one
            for(Metadata.CustomMetadata customMetadata : customMetadataList){
                Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
                mdContainer.addMetadata(customMetadata);
                System.debug('customMetadata -------------- '+customMetadata);
                // Enqueue custom metadata deployment, jobId is the deployment ID
                String jobIdSingle = Metadata.Operations.enqueueDeployment(mdContainer, callback);
                jobId += jobIdSingle+',';
                
            }
            
        }catch(Exception ex){
            ex.getMessage();
            System.debug('error in upsertMDT -- '+ex.getStackTraceString());
        }
        jobId = jobId.removeEnd(',');
        return jobId;
    }
    
    /**
* @description : Method to insert/update TriggerFrameworkProfile__mdt records
* @author : Nagendra Chinchinada | 6/10/2019
* @param  : TriggerFrameworkProfile__mdt records to be inserted/updated
* @return : Metadata records Deployment JobId as a string
*/
    public static string upsertProfile(TriggerFrameworkProfile__mdt profileRecord){
        Integer maxSize = 40;
        String profileName;
       
        CustomMetadataType metadataRecord = new CustomMetadataType();
        List<MDTFieldValue> mdtValues = new List<MDTFieldValue>();
        if(profileRecord.DeveloperName.length()>maxSize){
            profileName = profileRecord.DeveloperName.substring(0, maxSize);
            metadataRecord.label = removeSpclCharsForCustomMD(profileName);
        }
        else{
            //metadataRecord.DeveloperName = profileRecord.DeveloperName;
            metadataRecord.label = removeSpclCharsForCustomMD(profileRecord.DeveloperName);
        }
        if(String.isNotBlank(profileRecord.Profile_Id__c)){
            mdtValues.add(new MDTFieldValue('Profile_Id__c',profileRecord.Profile_Id__c));
            //mdtValues.add(new MDTFieldValue('DeveloperName',profileRecord.DeveloperName)); 
        }           
        if(profileRecord.Active__c <> null)
            mdtValues.add(new MDTFieldValue('Active__c',profileRecord.Active__c));
        metadataRecord.fieldValues = mdtValues;
        
        return upsertMDT('TriggerFrameworkProfile__mdt', new List<CustomMetadataType>{metadataRecord});
    }
    
    public static string upsertConfig(List<TriggerFrameworkConfig__mdt> configList){
        List<CustomMetadataType> customMetadataTypes = new List<CustomMetadataType>();
        List<MDTFieldValue> fieldValuesList = new List<MDTFieldValue>();
        for(TriggerFrameworkConfig__mdt configRec : configList){
            CustomMetadataType metadataRecord = new CustomMetadataType();
            //metadataRecord.label = configRec.Trigger_Event__c+'_'+configRec.DeveloperName;
            metadataRecord.label = configRec.DeveloperName;
            fieldValuesList.clear();
            //fieldValuesList.add(new MDTFieldValue('Id',configRec.Id));
            //fieldValuesList.add(new MDTFieldValue('DeveloperName',configRec.DeveloperName));
            fieldValuesList.add(new MDTFieldValue('Object_Name__c',configRec.Object_Name__c));
            fieldValuesList.add(new MDTFieldValue('Trigger_Event__c',configRec.Trigger_Event__c));
            fieldValuesList.add(new MDTFieldValue('Enabled__c',configRec.Enabled__c));
            fieldValuesList.add(new MDTFieldValue('Max_ReEntry__c',configRec.Max_ReEntry__c));
            fieldValuesList.add(new MDTFieldValue('Fields__c',configRec.Fields__c));
            fieldValuesList.add(new MDTFieldValue('Use_New_Transaction__c',configRec.Use_New_Transaction__c));
            fieldValuesList.add(new MDTFieldValue('HandlerClass_ExecutionOrder__c',configRec.HandlerClass_ExecutionOrder__c));
            fieldValuesList.add(new MDTFieldValue('Disabled__c',false));
            metadataRecord.fieldValues = fieldValuesList;
            customMetadataTypes.add(metadataRecord);
        }       
        return upsertMDT('TriggerFrameworkConfig__mdt', customMetadataTypes);
    }
    
    public static string upsertProfileConfig(List<TriggerFrameworkProfileConfig__mdt> profileConfigList){
        List<CustomMetadataType> customMetadataTypes = new List<CustomMetadataType>();
        System.debug('profileConfigList --- '+profileConfigList);
        //List<MDTFieldValue> fieldValuesList = new List<MDTFieldValue>();
        for(TriggerFrameworkProfileConfig__mdt profConfig : profileConfigList){
            CustomMetadataType metadataRecord = new CustomMetadataType();
            //metadataRecord.label = profConfig.DeveloperName+'_'+profConfig.Profile__c+'_'+profConfig.Config__c;
            String devName = profConfig.DeveloperName;//Contains # whic is required to get DeveloperName of objects
            metadataRecord.label = profConfig.Profile__c+'_'+profConfig.Config__c;//To avoid long name exception (max length is 40)
            //fieldValuesList.clear();
            List<MDTFieldValue> fieldValuesList = new List<MDTFieldValue>();
            //fieldValuesList.add(new MDTFieldValue('Id',profConfig.Id));
            fieldValuesList.add(new MDTFieldValue('Profile__c',devName.split('#')[0]));
            fieldValuesList.add(new MDTFieldValue('Config__c',devName.split('#')[1]));
            fieldValuesList.add(new MDTFieldValue('Disabled__c',false));
            metadataRecord.fieldValues = fieldValuesList;
            customMetadataTypes.add(metadataRecord);
        }
        return upsertMDT('TriggerFrameworkProfileConfig__mdt', customMetadataTypes);
    }
    
    public static string disableProfileConfig(List<TriggerFrameworkProfileConfig__mdt> profileConfigList){
        List<CustomMetadataType> customMetadataTypes = new List<CustomMetadataType>();
        List<MDTFieldValue> fieldValuesList = new List<MDTFieldValue>();
        for(TriggerFrameworkProfileConfig__mdt profConfig : profileConfigList){
            CustomMetadataType metadataRecord = new CustomMetadataType();
            //metadataRecord.label = profConfig.DeveloperName+'_'+profConfig.Profile__c+'_'+profConfig.Config__c;
            metadataRecord.label = profConfig.DeveloperName;
            fieldValuesList.clear();
            //fieldValuesList.add(new MDTFieldValue('Id',profConfig.Id));
            fieldValuesList.add(new MDTFieldValue('Disabled__c',profConfig.Disabled__c));
            metadataRecord.fieldValues = fieldValuesList;
            customMetadataTypes.add(metadataRecord);
        }       
        return upsertMDT('TriggerFrameworkProfileConfig__mdt', customMetadataTypes);
    }
    
    public static string disableConfig(List<TriggerFrameworkConfig__mdt> profileConfigList){
        List<CustomMetadataType> customMetadataTypes = new List<CustomMetadataType>();
        List<MDTFieldValue> fieldValuesList = new List<MDTFieldValue>();
        for(TriggerFrameworkConfig__mdt configRec : profileConfigList){
            CustomMetadataType metadataRecord = new CustomMetadataType();
            //metadataRecord.label = configRec.Trigger_Event__c+'_'+configRec.DeveloperName;
            metadataRecord.label = configRec.DeveloperName;
            fieldValuesList.clear();        
            //fieldValuesList.add(new MDTFieldValue('Id',configRec.Id));
            fieldValuesList.add(new MDTFieldValue('Disabled__c',configRec.Disabled__c));
            metadataRecord.fieldValues = fieldValuesList;
            customMetadataTypes.add(metadataRecord);
        }       
        return upsertMDT('TriggerFrameworkConfig__mdt', customMetadataTypes);
    }
    
    public class CustomMetadataType{
        public String label {get; set;}
        public List<MDTFieldValue> fieldValues {get; set;}
    }
    public class MDTFieldValue{
        public MDTFieldValue(String field, Object value){
            this.field = field;
            this.value = value;
        }
        
        public String field {get; set;}
        public Object value {get; set;}
    }
    public static String removeSpclCharsForCustomMD(String strText){
         
        return strText.replaceAll('[^a-zA-Z0-9_\\s+]', '');
    } 
}