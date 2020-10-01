public virtual class AccountBeforeUpdateHelperCore implements TriggerFramework.IHandler{   
    public void execute(TriggerFramework.Context context) {
        List<Account> newList = (List<Account>)context.newList;
        Map<Id, Account> newMap = (Map<Id, Account>)context.newMap;
        Map<Id, Account> oldMap = (Map<Id, Account>)context.oldMap;
        List<ContactClinicChangeWrapper> payload = CreateAccountShares(newList,oldMap);  
         ContactClinicChangeHandler.SharePositiveCases(payload);
    }  
    public List<ContactClinicChangeWrapper> CreateAccountShares(List<Account> newList ,Map<Id, Account> oldMap ){
        List<ContactClinicChangeWrapper> payload = new List<ContactClinicChangeWrapper>();
         for ( Account acct: newList) {
            // Access the "old" record by its ID in Trigger.oldMap
            Account oldAcct = oldMap.get(acct.Id);            
            // Trigger.new records are conveniently the "new" versions!            
            if(acct.Home_Location__pc != oldAcct.Home_Location__pc)
            {
                String contactClinicGroupID = ContactChangeUtility.getContactClinincGroupID(acct.Home_Location__pc);
                List<case> contactcases = ContactChangeUtility.getContactCases(acct.ID);
               if(contactcases != null) 
                {
                    ContactClinicChangeWrapper cccw = new ContactClinicChangeWrapper();
                    cccw.cntct = acct;
                    cccw.contactClinicGroupID = contactClinicGroupID;
                    cccw.contactCases.addAll(contactcases); 
                    // map of positive case ID and corresponding contact (Location)
                    cccw.positiveCases = ContactChangeUtility.getPositiveContactCases(contactcases);
                    cccw.ownPositiveCases = ContactChangeUtility.getOwnPositiveCases(acct.ID);
                    payload.add(cccw);                    
                }                                              
            }               
        }
        return payload ;
    }
}