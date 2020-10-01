/******************************************************************************
* Apex Class Name : ChangeCaseOwner        
* Version         : 44.0          
* Function        : This class is for mass change Owner functionality
Developer          Date           Description            US Number
-------------------------------------------------------------------------------------
Alexandria Sanborn	4/24/2020	create methods to 		
***/
public without sharing class ChangeCaseOwner {
    private static final string STRINGLIKE = '%';
    private static final string STRINGQUEUE ='Queue';
    private static final string STRINGUSER ='User';
    private static final string STRINGUNDEFINED = 'undefined';
    private static final string STRINGEMPTY = '';
    private static final String CLASSNAME = 'ChangeCaseOwner';
    private static final String METHOD_SAVELOGIC = 'updateOwners';
    private static final string METHOD_FETCHUSERQUEUE = 'fetchUserList';
    private static final string METHOD_FETCHQUEUELIST = 'fetchQueueList';
    private static final string METHOD_GETURL='getURL';
    
    /***************************************************************
* Method Name  : fetchUsers
* @description : This method is used to list out Users via search input on name
* @parameters  :  list<group> queuelist
* @Author      : Alexandria Sanborn
*************************************************************/   
    @AuraEnabled
    public static List<User> fetchUserList(String searchKeyWord) {
        list<case> result=new list<case>();
        try{
                String searchKey = STRINGLIKE + searchKeyWord + STRINGLIKE;
                return [select id, Name from user where Name LIKE: searchKey AND Isactive=TRUE ORDER BY Name LIMIT 500];            
        }
        catch(Exception ex){
            System.debug(ex.getMessage());
            throw new AuraHandledException(ex.getMessage());
        } 
    }

    @AuraEnabled
    public static List<Group> fetchQueueList(){
        List<string> queueNames = new List<string>();
        try{
            return [SELECT id,Name FROM Group WHERE Type='Queue'];
        }
        catch(Exception ex){ 
            System.debug(ex.getMessage());
            throw new AuraHandledException(ex.getMessage());
        } 
        
    }
    /***************************************************************
* Method Name  : updateCaseOwner
* @description : This method is used to save the new changed Owner of the case
* @parameters  :  string newOwnerId, List<Case> casesToReassign
* @return      : 
* @Author      : 
*************************************************************/
    @AuraEnabled
    public static Integer updateCaseOwner(String newOwnerId,String[] casesToReassign){
        System.debug(newOwnerId);
        System.debug(casesToReassign);
        Case[] casesToUpdate = new Case[]{};
        try{
            for(String caseId:casesToReassign){
                casesToUpdate.add(new Case(id=caseId, OwnerId=newOwnerId));
            }
            Database.update(casesToUpdate);
            return casesToUpdate.size();
        }
        catch(Exception ex){
            System.debug(ex.getMessage());
            throw new AuraHandledException(ex.getMessage());
        }  
    }
}