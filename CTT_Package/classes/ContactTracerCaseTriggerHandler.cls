public class ContactTracerCaseTriggerHandler {

    
 public static void BeforeInsertHandler(List<case> newcases){
        Map<String, String> caseAcctMap = new Map<String, String>();
         Map<String, case> caseMap = new Map<String, case>();
     Id possitiveRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Positive Outreach').getRecordTypeId();
      Id contactRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Contact Outreach').getRecordTypeId();

        for(case c : newcases){
   if(c.RecordTypeId == possitiveRecordTypeId || c.RecordTypeId == contactRecordTypeId ){             
            caseAcctMap.put(c.id, c.accountId);
            caseMap.put(c.id, c);
            }
        }
     if(caseMap.size() > 0)  {     
   List<String> accoutIds = new List<String>(caseAcctMap.values());
             Set<String> uniqueAcctIds = new Set<String>();
   uniqueAcctIds.addAll(accoutIds);
   Map<Id, Account> acctMap = new Map<ID, Account>([SELECT Id, personcontactid FROM Account where id in :uniqueAcctIds ]);
      
        for(String caseId : caseAcctMap.keySet() ){
               String acctId = caseAcctMap.get(caseId);
         String pcID =   acctMap.get(acctId).personcontactid;
           case c = caseMap.get(caseId);
            c.contactId = pcID;
            
            }
     list<case> updcases = caseMap.values();
        update updcases;
     }
    }
   
    public static void BeforeUpdateHandler(Map<Id, Case> oldCases, Map<Id, Case> newCases){
        Map<String, String> caseAcctMap = new Map<String, String>();
         Map<String, case> caseMap = new Map<String, case>();
        
        for(id cId : oldCases.keyset()){
            
            if(oldCases.get(cId).accountId != newCases.get(cId).accountId){
                system.debug('acctId '+oldCases.get(cId).accountId);
                system.debug('new acctId '+newCases.get(cId).accountId);
             caseMap.put(cId,newCases.get(cId));
                caseAcctMap.put(cId, newCases.get(cId).accountId);                
            }
              if(caseMap.size() > 0)  {  
                  system.debug('size'+caseMap.size());
   List<String> accoutIds = new List<String>(caseAcctMap.values());
             Set<String> uniqueAcctIds = new Set<String>();
   uniqueAcctIds.addAll(accoutIds);
   Map<Id, Account> acctMap = new Map<ID, Account>([SELECT Id, personcontactid FROM Account where id in :uniqueAcctIds ]);
      
        for(String caseId : caseAcctMap.keySet() ){
               String acctId = caseAcctMap.get(caseId);
         String pcID =   acctMap.get(acctId).personcontactid;
           case c = caseMap.get(caseId);
            c.contactId = pcID;
            
            }
     list<case> updcases = caseMap.values();
        update updcases;
     }
        }
        
    }
}