public without sharing class ContactClinicChangeHandler {
    public static void SharePositiveCases(List<ContactClinicChangeWrapper> cccwList){        
        List<caseShare> newCaseShares = CreateShareRecords(cccwList);                   
        try{
            if(newCaseShares.size()>0){
                Database.SaveResult[] lsr = Database.insert(newCaseShares,false);
            }
        }
        catch(DmlException e){
            System.debug('Exception Occured: '+ e.getMessage());    
                         
        }
    }     
    public static List<caseShare> CreateShareRecords(List<ContactClinicChangeWrapper> cccwList){        
        List<caseShare> newCaseShares = new List<caseShare>();        
        if (cccwList!=null && cccwList.size()>0){
            for(ContactClinicChangeWrapper cccw : cccwList){
                List<caseShare> caseShareList = contactChangeUtility.ShareContactCasesToNewClinic(cccw);
                newCaseShares.addAll(caseShareList);
                for (case positiveCase : cccw.positiveCases){
                    caseShare  curCaseShare =  InitPositiveCaseShare(cccw, positiveCase);                       
                    if (curCaseShare != null){
                        newCaseShares.add(curCaseShare);                                                                                         
                    }              
                }
            }            
        }             
        return newCaseShares;
    }    
    public static caseShare InitPositiveCaseShare(ContactClinicChangeWrapper cccw,case positiveCase ){
        caseShare curCaseShare = new caseShare();
        if(positiveCase.Contact.Home_Location__c != cccw.cntct.Home_Location__pc){         
            curcaseShare.caseID = positiveCase.ID;
            curcaseShare.userorgroupID = cccw.ContactClinicGroupID;
            curcaseShare.caseaccesslevel = 'Read';
            curcaseShare.RowCause = Schema.CaseShare.RowCause.Manual; 
            return curcaseShare;
        }
        return null;        
    }
}