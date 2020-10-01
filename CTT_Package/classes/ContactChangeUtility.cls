Public without sharing Class ContactChangeUtility {
   public static String getContactClinincGroupID(String LocationName)          
    {
        CTT_Location_Group__mdt groupName = [SELECT Sharing_Group_Name__c FROM CTT_Location_Group__mdt WHERE Location_Name__c = :LocationName Limit 1];
        Group groupId = [SELECT Id FROM Group WHERE Name = :groupName.Sharing_Group_Name__c Limit 1];        
        return groupId.id;
    }    
    public static List<case> getContactCases( ID acctID )       
    {
        List<case> cases = new List<case>();
        cases = [select ID, parentid from case where recordtype.name = 'Contact Outreach' and accountID = :acctID  ];
        return cases;
    }    
    public static List<case> getOwnPositiveCases( ID acctID )       
    {
        List<case> ownPositiveCases = new List<case>();
        ownPositiveCases = [select ID, parentid from case where recordtype.name = 'Positive Outreach' and accountID = :acctID  ];
        return ownPositiveCases;
    }
    public static List<Case> getPositiveContactCases(List<Case> contactCaseList)            
    {        
       set<String> parentIds = new Set<String>();      
        for(Case parIds : contactCaseList){
            parentIds.add(parIds.parentId);
        }
        List<case> posCaseList = new List<case>();
        posCaseList = [select ID, contact.Home_Location__c from case where id in :ParentIds];
        return posCaseList;  
    }    
    public static List<caseShare> ShareContactCasesToNewClinic( ContactClinicChangeWrapper cccw )        
    {
        List<caseShare> newCaseShares = new List<caseShare>();
        List<case> newCases = new List<case>();
        newCases.addAll(cccw.contactCases);
        newCases.addAll(cccw.ownPositiveCases);
        for(case c : newCases)
        {
            caseShare curCaseShare = new caseShare();
            curcaseShare.caseID = c.id;
            curcaseShare.userorgroupID = cccw.ContactClinicGroupID;
            curcaseShare.caseaccesslevel = 'Edit';
            newCaseShares.add(curcaseShare);
        }
        return newCaseShares;        
    } 
}