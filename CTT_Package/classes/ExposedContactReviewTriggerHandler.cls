/**********************************************************************
@CreatedDate    28/04/2020                                    
@ModifiedDate                                   
@author          Arnab
@Description     Trigger Handler for Exposed_Contact_Review__c object
@Requirement Id  
@Test Class      
***********************************************************************/
public without sharing class ExposedContactReviewTriggerHandler {
    public static final String  CONTACT_OUTREACH_RECORDTYPE_ID= Schema.Sobjecttype.Case.getRecordTypeInfosByDeveloperName().get('Contact_Outreach').getRecordTypeId();
    public static final String  COMMUNITY_USER_RECORDTYPE_ID= Schema.Sobjecttype.Exposed_Contact_Review__c.getRecordTypeInfosByDeveloperName().get('Community_User').getRecordTypeId();
    public static final String  AGENT_USER_RECORDTYPE_ID= Schema.Sobjecttype.Exposed_Contact_Review__c.getRecordTypeInfosByDeveloperName().get('Agent_User').getRecordTypeId();
    public static final String  AWAITING_OUTREACH='AwaitingOutreach';
    public static final String  REVIEW_COMPLETED='Review Completed';
    
    public static void onAfterInsert(Map<Id, Exposed_Contact_Review__c> newExposedContacts){
        Map<Id, Exposed_Contact_Review__c> newExposedContactForConvert = new Map<Id, Exposed_Contact_Review__c>();
        for(Exposed_Contact_Review__c ec : newExposedContacts.values()) {
            if(AGENT_USER_RECORDTYPE_ID.equals(ec.recordtypeId)){
                newExposedContactForConvert.put(ec.Id,ec);
            }
            
        }
        if(!newExposedContactForConvert.isEmpty()){
            mapExposedCotactTOCase(newExposedContactForConvert);
        }
    }
    public static void onAfterUpdate(Map<Id, Exposed_Contact_Review__c> oldExposedContacts,Map<Id, Exposed_Contact_Review__c> newExposedContacts){
        Map<Id, Exposed_Contact_Review__c> newExposedContactForConvert = new Map<Id, Exposed_Contact_Review__c>();
        for(Exposed_Contact_Review__c ec : newExposedContacts.values()) {
            if(COMMUNITY_USER_RECORDTYPE_ID.equals(ec.recordtypeId)){
                if(!String.isBlank(ec.Status__c) && REVIEW_COMPLETED.equalsIgnoreCase(ec.Status__c)){
                    newExposedContactForConvert.put(ec.Id,ec);
                }
            }
        }
        if(!newExposedContactForConvert.isEmpty()){
            mapExposedCotactTOCase(newExposedContactForConvert);
        }
    }
    public static void mapExposedCotactTOCase(Map<Id, Exposed_Contact_Review__c> newExposedContact){
        List<Case> casesToInsert = new List<Case>();
        Map<String,String> mapOfFields = new Map<String,String>();
        List<String> exposedContactListFields = new List<String>();
        List<String> caseListFields = new List<String>();
        List<ID> exposedContactIds = new List<ID>();
        
        for (Id eCId : newExposedContact.keySet()){
            exposedContactIds.add(eCId);
        }
        
        
        for(Patient_information_map__mdt p : [SELECT masterlabel,Exposed_Contact_Field__c,Case_Field__c FROM Patient_information_map__mdt]){
            mapOfFields.put(p.Case_Field__c,p.Exposed_Contact_Field__c);
            exposedContactListFields.add(p.Exposed_Contact_Field__c);
            caseListFields.add(p.Case_Field__c);
        }
        String fullQuery_start = 'SELECT id,';
        String fullQuery_end = ' FROM Exposed_Contact_Review__c WHERE Id IN :exposedContactIds';
        String queryLine = String.join(mapOfFields.values(),',');
        system.debug('@@@queryLine'+queryLine);
        String query = fullQuery_start + queryLine + fullQuery_end;
        system.debug('@@fullQuery_cmplt'+query);
        
        for(Exposed_Contact_Review__c cr : (List<Exposed_Contact_Review__c>)Database.query(query)) {
            Case newcase = new Case();
            for(String fieldname : mapOfFields.keySet()){
                if(cr.get(mapOfFields.get(fieldname))!=null){       
                    newcase.put(fieldname,cr.get(mapOfFields.get(fieldname)));
                }
            }
            newcase.recordtypeId = CONTACT_OUTREACH_RECORDTYPE_ID;
            newcase.Status=AWAITING_OUTREACH;
            casesToInsert.add(newcase);
        }
        
        
        
        system.debug('@@casesToInsert'+casesToInsert);
        
        if(!casesToInsert.isEmpty()){
            try{
                
                insert casesToInsert;
                system.debug('@@casesToInserted'+casesToInsert);
                
            }catch(exception e){
                
                throw e;
                
            }
        }
    }
}