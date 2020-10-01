public without sharing class ContactClinicChangeWrapper {
	public Account cntct {get;set;}
    public List<Case> contactCases = new List<Case>();
    public String contactClinicGroupID {get; set;}
    public List<case> positiveCases = new List<Case>();
    public List<case> ownPositiveCases = new List<Case>(); 
}