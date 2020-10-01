public without sharing class MassChangeOwnerExtension {
    private ApexPages.StandardSetController standardController;
    public String selectedCases {get; set;}
    public String url {get; set;}
    public Boolean displayChangeOwner {get; set;}
    public Boolean displayNoCases {get; set;}
    public Boolean displayNoPermission {get; set;}
    private static final String SUPERVISOR_PROFILE = 'CTC Supervisor';
    private static final String SYSTEM_ADMIN_PROFILE = 'System Administrator';
    
    
    public MassChangeOwnerExtension(ApexPages.StandardSetController standardController){
        this.standardController = standardController;
        
        Boolean profileCheck = checkProfilePermission();
        
        List<Case> selectedRecs = (List<Case>) standardController.getSelected();
        if(selectedRecs != null && !selectedRecs.isEmpty()){
            List<String> tempList = new List<String>();
            selectedRecs = [Select Id From Case Where Id IN: selectedRecs];
            for(Case rec: selectedRecs){
                tempList.add(rec.Id);
            }
            selectedCases = JSON.serialize(tempList);
            PageReference pageRef = new ApexPages.Action('{!List}').invoke();
            if(pageRef!=null){
                url = pageRef.getUrl();
            }
        }
        
        displayChangeOwner = false;
        displayNoCases = false;
        displayNoPermission = false;
        
        if((profileCheck && selectedRecs.size() > 0) || selectedRecs.size() == 1){
            displayChangeOwner = true;
        } else if (selectedRecs.size() == 0){
            displayNoCases = true;
        } else {
            displayNoPermission = true;
        }
        
    }
    
    private Boolean checkProfilePermission(){
        Id profileId=userinfo.getProfileId();
		String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        return profileName == SUPERVISOR_PROFILE || profileName == SYSTEM_ADMIN_PROFILE ? true : false;
    }
        
    
    public PageReference BackToList(){
        PageReference pageRef = new ApexPages.Action('{!List}').invoke();
        return pageRef;
    }
}