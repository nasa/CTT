/**
 * Controller for CaseContactMap
 *
 * @author  Frisia Xue
 * @since   2020-03-31
 */
public class CaseContactMapCtrl {
	@AuraEnabled
    public static List<mapMarkerWrapper> getAdressDetails(String caseId){
    /*
     * If there is a Case.Contact defined, Case.Contact.MailingAddress. 
     * If not, then pull in the Case.Account.BillingAddress. 
	*/
        List<mapMarkerWrapper> mapMarkerList = new List<mapMarkerWrapper>();
        mapMarkerWrapper mapMarker = new mapMarkerWrapper();
        locationWrapper loc = new locationWrapper();
        Case cs = [select ContactId, AccountId from Case where Id=:caseId limit 1];
        if (cs.ContactId!=Null){
            Contact cnt = [SELECT Id, MailingStreet, MailingCity, MailingState, Name FROM Contact where Id = :cs.ContactId limit 1];
            loc.Street = cnt.MailingStreet;
            loc.City = cnt.MailingCity;
            loc.State = cnt.MailingState;
            mapMarker.title = cnt.Name;   
        } else {
            Account acct = [SELECT Id, BillingStreet, BillingCity, BillingState, Name FROM Account where Id = :cs.AccountId limit 1];
            loc.Street = acct.BillingStreet;
            loc.City = acct.BillingCity;
            loc.State = acct.BillingState;
            mapMarker.title = acct.Name;
        }
        mapMarker.location = loc;
        mapMarkerList.add(mapMarker);
        System.debug('The street is ' + mapMarkerList[0].location.Street);
        System.debug('The title is ' + mapMarkerList[0].title);
        return mapMarkerList;
	}
    
    public class locationWrapper{
        @AuraEnabled
        public String Street {get; set;}
        @AuraEnabled
        public String City{get; set;}
        @AuraEnabled
        public String State{get; set;}
    }
    
    public class mapMarkerWrapper{
		@AuraEnabled
        public locationWrapper location {get; set;} 
        @AuraEnabled
        public String title {get; set;}
        
        
    }
}