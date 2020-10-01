/**
* OWASP Enterprise Security API (ESAPI)
* 
* This file is part of the Open Web Application Security Project (OWASP)
* Enterprise Security API (ESAPI) project. For details, please see
* <a href="http://www.owasp.org/index.php/ESAPI">http://www.owasp.org/index.php/ESAPI</a>.
*
* Copyright (c) 2010 - Salesforce.com
* 
* The Apex ESAPI implementation is published by Salesforce.com under the New BSD license. You should read and accept the
* LICENSE before you use, modify, and/or redistribute this software.
* 
* @author Yoel Gluck (securecloud .at. salesforce.com) <a href="http://www.salesforce.com">Salesforce.com</a>
* @created 2010
*/

/**
* This class contains unit tests for validating the behavior of Apex classes
* and triggers.
*
* Unit tests are class methods that verify whether a particular piece
* of code is working properly. Unit test methods take no arguments,
* commit no data to the database, and are flagged with the testMethod
* keyword in the method definition.
*
* All test methods in an organization are executed whenever Apex code is deployed
* to a production organization to confirm correctness, ensure code
* coverage, and prevent regressions. All Apex classes are
* required to have at least 75% code coverage in order to be deployed
* to a production organization. In addition, all triggers must have some code coverage.
* 
* The @isTest class annotation indicates this class only contains test
* methods. Classes defined with the @isTest annotation do not count against
* the organization size limit for all Apex scripts.
*
* See the Apex Language Reference for more information about Testing and Code Coverage.
*/
@isTest
private class testAccessController {
    
    // Baseline Lead fields that will be accessible when using the ReadOnly profile and createFieldPermissions()
    private static List<String> fieldsToCheck = new List<String>{'LastName','Status','Email'};
        
        static ObjectPermissions contactObjectReadPermission = new ObjectPermissions(SobjectType = 'Lead',
                                                                                     PermissionsCreate = false,
                                                                                     PermissionsDelete = false,
                                                                                     PermissionsEdit = false,
                                                                                     PermissionsRead = true
                                                                                    );
    
    static ObjectPermissions contactObjectCreateEditReadPermission = new ObjectPermissions(SobjectType = 'Lead',
                                                                                           PermissionsCreate = true,
                                                                                           PermissionsDelete = false,
                                                                                           PermissionsEdit = true,
                                                                                           PermissionsRead = true
                                                                                          );
    
    static ObjectPermissions contactObjectCreateReadPermission = new ObjectPermissions(SobjectType = 'Lead',
                                                                                       PermissionsCreate = true,
                                                                                       PermissionsDelete = false,
                                                                                       PermissionsEdit = false,
                                                                                       PermissionsRead = true
                                                                                      );
    
    static ObjectPermissions contactObjectEditReadPermission = new ObjectPermissions(SobjectType = 'Lead',
                                                                                     PermissionsCreate = false,
                                                                                     PermissionsDelete = false,
                                                                                     PermissionsEdit = true,
                                                                                     PermissionsRead = true
                                                                                    );
    
    static ObjectPermissions contactObjectDeleteEditReadPermission = new ObjectPermissions(SobjectType = 'Lead',
                                                                                           PermissionsCreate = false,
                                                                                           PermissionsDelete = true,
                                                                                           PermissionsEdit = true,
                                                                                           PermissionsRead = true
                                                                                          );
    
    static testMethod void testAccessControl() {
        Lead leadRecord = new Lead(
                LastName = 'ESAPI Test Spu8UY&thuCrUzAPa2ASTaC7rA$Ra3 c Limits ',
                Status = 'Open',
                Email='thuCrUzAPa2ASTalimits@thuCrUzAPa2ASTaC7rA.com',
                Company = 'HarbhajanTravels'
            );
        
        String errStr;
        
        try {
            ESAPI.accessController().setOperationMode(SFDCAccessController.OperationMode.ALL_OR_NONE);
            ESAPI.accessController().setSharingMode(SFDCAccessController.SharingMode.WITH);
            
            leadRecord = (Lead)ESAPI.accessController().insertAsUser(leadRecord, new List<String>{'LastName','Status','Email','Company'});
            //leadRecord = (Lead)ESAPI.accessController().insertAsUser(leadRecord, new List<Schema.SObjectField>{Lead.LastName,Lead.Status,Lead.Email});
            
            ESAPI.accessController().getCreatableFields(leadRecord);
            ESAPI.accessController().getUpdateableFields(leadRecord);
            ESAPI.accessController().getViewableFields(leadRecord);
            
            ESAPI.accessController().getCreatableFields(Lead.getSObjectType());
            ESAPI.accessController().getUpdateableFields(Lead.getSObjectType());
            ESAPI.accessController().getViewableFields(Lead.getSObjectType());
            
            leadRecord.LastName = 'ESAPI Test Spu8UY&thuCrUzAPa2ASTaC7rA$Ra3 updated';
            ESAPI.accessController().updateAsUser(leadRecord, new List<String>{'LastName'});
            ESAPI.accessController().updateAsUser(leadRecord, new List<Schema.SObjectField>{Lead.LastName});
            ESAPI.accessController().deleteAsUser(leadRecord);
            
            leadRecord = new Lead();
            leadRecord.LastName = 'ESAPI Test2 Spu8UY&thuCrUzAPa2ASTaC7rA$Ra3'; // We add this long random to make sure we will not conflict with any real last name
            leadRecord.Company = 'JumabkuchaInter';
            ESAPI.accessController().setOperationMode(SFDCAccessController.OperationMode.BEST_EFFORT);
            ESAPI.accessController().setSharingMode(SFDCAccessController.SharingMode.WITHOUT);
            leadRecord = (Lead)ESAPI.accessController().insertAsUser(leadRecord, new List<String>{'LastName','Company'});
            
            leadRecord.LastName = 'ESAPI Test2 Spu8UY&thuCrUzAPa2ASTaC7rA$Ra3 updated';
            ESAPI.accessController().updateAsUser(leadRecord, new List<String>{'LastName'});
            ESAPI.accessController().deleteAsUser(leadRecord);
            
            leadRecord = new Lead();
            leadRecord.LastName = 'ESAPI Test3 Spu8UY&thuCrUzAPa2ASTaC7rA$Ra3'; // We add this long random to make sure we will not conflict with any real last name
            leadRecord.Company = 'JingichaInter';
            ESAPI.accessController().setOperationMode(SFDCAccessController.OperationMode.BEST_EFFORT);
            ESAPI.accessController().setSharingMode(SFDCAccessController.SharingMode.INHERIT);
            leadRecord = (Lead)ESAPI.accessController().insertAsUser(leadRecord, new List<String>{'LastName','Company'});
            
            leadRecord.LastName = 'ESAPI Test3 Spu8UY&thuCrUzAPa2ASTaC7rA$Ra3 updated';
            ESAPI.accessController().updateAsUser(leadRecord, new List<String>{'LastName'});
            ESAPI.accessController().deleteAsUser(leadRecord);
            
        } catch (SFDCAccessControlException e) {
            errStr = 'Access control violation - Type: ' + e.getExceptionType() + ' Reason: '  
                + e.getExceptionReason() + ' Object: ' + e.getExceptionObject() + ' Field: '  
                + e.getExceptionField() + ' Text: ' + e.getText(); 
        }
        
        SFDCAccessController ac = new SFDCAccessController(SFDCAccessController.SharingMode.WITHOUT, SFDCAccessController.OperationMode.ALL_OR_NONE);
        ESAPI.accessController().setOperationMode(SFDCAccessController.OperationMode.BEST_EFFORT);
        
        try {
            ESAPI.accessController().setOperationMode(null);
            System.assert(false, 'Should never get here');
        } catch (SFDCAccessController.AccessControlDmlException e) {
            // should fail - so all good
        }
        
        try {
            ESAPI.accessController().setSharingMode(null);
            System.assert(false, 'Should never get here');
        } catch (SFDCAccessController.AccessControlDmlException e) {
            // should fail - so all good
        }
        
        try {
            ESAPI.accessController().setArrayOperationMode(null);
            System.assert(false, 'Should never get here');
        } catch (SFDCAccessController.AccessControlDmlException e) {
            // should fail - so all good
        }
        
        try {
            leadRecord = new Lead();
            leadRecord.LastName = 'ESAPI Test4 Spu8UY&thuCrUzAPa2ASTaC7rA$Ra3'; // We add this long random to make sure we will not conflict with any real last name
            
            ESAPI.accessController().setOperationMode(SFDCAccessController.OperationMode.ALL_OR_NONE);
            ESAPI.accessController().setSharingMode(SFDCAccessController.SharingMode.WITH);
            string fieldNameThatDoesNotExist = 'LastName123DOESNOTEXIST';
            ESAPI.accessController().insertAsUser(leadRecord, new List<String>{fieldNameThatDoesNotExist}); // The requested field doesn't exist.
            
            System.assert(false, 'Should never get here. Not expecting access to field LastName123DOESNOTEXIST');
        } catch (SFDCAccessControlException e) {
            // should fail - so all good
            errStr = 'Access control violation - Type: ' + e.getExceptionType() + ' Reason: '  
                + e.getExceptionReason() + ' Object: ' + e.getExceptionObject() + ' Field: '  
                + e.getExceptionField() + ' Text: ' + e.getText(); 
            
            System.assertEquals(SFDCAccessControlException.ExceptionReason.NO_CREATE, e.getExceptionReason());
            System.assertEquals('Access Violation', e.getText());
            System.assertEquals(SFDCAccessControlException.ExceptionType.FIELD_ACCESS_VIOLATION, e.getExceptionType());
        }
    }
    
    //#region Insert
    
    // No access to sObject at all
    @isTest
    static void runasProfileNoInsertSObject() {
        runasProfileNoInsertSObject_Internal(false, false);
    }
    
    @isTest
    static void runasProfileNoInsertSObjects() {
        runasProfileNoInsertSObject_Internal(true, false);
    }
    
    @isTest
    static void runasProfileNoInsertSObject_asSObjectField() {
        runasProfileNoInsertSObject_Internal(false, true);
    }
    
    @isTest
    static void runasProfileNoInsertSObjects_asSObjectField() {
        runasProfileNoInsertSObject_Internal(true, true);
    }
    
    static void runasProfileNoInsertSObject_Internal(boolean asCollection, boolean asSObjectField) {
        
        User u = testReadOnlyProfileUser(false);
        
        System.runAs(u) {
            try {
                Lead leadRecord = new Lead(
                    LastName = 'ESAPI Test Spu8UY&thuCrUzAPa2ASTaC7rA$Ra3 c Limits',
                    Status = 'Open',
                Email='thuCrUzAPa2ASTalimits@thuCrUzAPa2ASTaC7rA.com'
                );
                
                
                ESAPI.accessController().setOperationMode(SFDCAccessController.OperationMode.ALL_OR_NONE);
                ESAPI.accessController().setSharingMode(SFDCAccessController.SharingMode.WITH);
                
                if(asSObjectField) {
                    if(asCollection) {
                        ESAPI.accessController().insertAsUser(new List<Lead>{leadRecord}, new List<Schema.SObjectField>{Lead.LastName, Lead.Status, Lead.Email});
                    } else {
                        ESAPI.accessController().insertAsUser(leadRecord, new List<Schema.SObjectField>{Lead.LastName, Lead.Status, Lead.Email});
                        
                    }
                } else {
                    if(asCollection) {
                        ESAPI.accessController().insertAsUser(new List<Lead>{leadRecord}, new List<String>{'LastName','Status','Email'});
                    } else {
                        ESAPI.accessController().insertAsUser(leadRecord, new List<String>{'LastName','Status','Email'});
                    }
                }
                
                System.assert(false, 'Should never get here. Not expected to have create access for Lead');
            }  catch (SFDCAccessControlException e) {
                // should fail - so all good
                string errStr = 'Access control violation - Type: ' + e.getExceptionType() + ' Reason: '  
                    + e.getExceptionReason() + ' Object: ' + e.getExceptionObject() + ' Field: '  
                    + e.getExceptionField() + ' Text: ' + e.getText(); 
                
                System.assertEquals(SFDCAccessControlException.ExceptionReason.NO_CREATE, e.getExceptionReason());
                System.assertEquals('Access Violation', e.getText());
                //System.assertEquals(SFDCAccessControlException.ExceptionType.OBJECT_ACCESS_VIOLATION, e.getExceptionType());
            }
        }
    }
    
    // No access to field on sObject create
    @isTest
    static void runasProfileNoInsertSObjectField() {
        runasProfileNoInsertSObjectField_Internal(false, false);
    }
    
    @isTest
    static void runasProfileNoInsertSObjectsField() {
        runasProfileNoInsertSObjectField_Internal(true, false);
    }
    
    @isTest
    static void runasProfileNoInsertSObjectField_asSObjectField() {
        runasProfileNoInsertSObjectField_Internal(false, true);
    }
    
    @isTest
    static void runasProfileNoInsertSObjectsField_asSObjectField() {
        runasProfileNoInsertSObjectField_Internal(true, true);
    }
    
    
    
    // No access to field on sObject create
    static void runasProfileNoInsertSObjectField_Internal(boolean asCollection, boolean asSObjectField) {
        
        FieldPermissions doNoCallFieldPermission = new FieldPermissions(SobjectType ='Lead',
                                                                        Field = 'Lead.DoNotCall',
                                                                        PermissionsRead = true,
                                                                        PermissionsEdit = false
                                                                       );   
        
        boolean createReadWriteFieldPermissions = true;
        User u = testReadOnlyProfileUser(true, contactObjectCreateEditReadPermission, createReadWriteFieldPermissions, new FieldPermissions[]{doNoCallFieldPermission} );
        
        System.runAs(u) {
            try {
                Lead c = new Lead();
                c.LastName = 'ESAPI Test4 Spu8UY&thuCrUzAPa2ASTaC7rA$Ra3';
                c.DoNotCall = true;
                c.Status = 'Open';
                c.Email = 'xyz@gmail.com';
                c.Company = 'JacksonInter';
                System.assert(SObjectType.Lead.createable);
                System.assert(SObjectType.Lead.fields.DoNotCall.isAccessible(), 'The Lead.DoNotCall field should be Accessible.');
                System.assert(!SObjectType.Lead.fields.DoNotCall.isCreateable(), 'The Lead.DoNotCall field should not be Createable. Just Readable');
                //System.assert(SObjectType.Lead.fields.Description.isCreateable());
                
                ESAPI.accessController().setOperationMode(SFDCAccessController.OperationMode.ALL_OR_NONE);
                ESAPI.accessController().setSharingMode(SFDCAccessController.SharingMode.WITH);
                
                List<string> contactFieldsToCheck = new List<String>{'LastName', 'Status', 'DoNotCall', 'Email','Company'};
                    
                    if(asSObjectField) {
                        List<Schema.SObjectField> contactSObjectFieldsToCheck = schemaSObjectFields(Schema.Lead.getSobjectType(), contactFieldsToCheck);
                        
                        if(asCollection) {
                            ESAPI.accessController().insertAsUser(new List<Lead>{c}, contactSObjectFieldsToCheck);
                        } else {
                            ESAPI.accessController().insertAsUser(c, contactSObjectFieldsToCheck);
                        }
                    } else {
                        if(asCollection) {
                            ESAPI.accessController().insertAsUser(new List<Lead>{c}, contactFieldsToCheck );
                        } else {
                            ESAPI.accessController().insertAsUser(c, contactFieldsToCheck);
                        }
                    }
                
                System.assert(false, 'Should never get here. Not expected to have permission to insert the Lead.DoNotCall field');
            }  catch (SFDCAccessControlException e) {
                // should fail - so all good
                string errStr = 'Access control violation - Type: ' + e.getExceptionType() + ' Reason: '  
                    + e.getExceptionReason() + ' Object: ' + e.getExceptionObject() + ' Field: '  
                    + e.getExceptionField() + ' Text: ' + e.getText(); 
                
                System.assertEquals(SFDCAccessControlException.ExceptionReason.NO_CREATE, e.getExceptionReason());
                System.assertEquals('Access Violation', e.getText());
                System.assertEquals(SFDCAccessControlException.ExceptionType.FIELD_ACCESS_VIOLATION, e.getExceptionType());
                System.assertEquals('Lead', e.getExceptionObject() + '');
                if(asSObjectField) {
                    System.assertEquals('DoNotCall', e.getExceptionField() + '');
                } else {
                    System.assertEquals('donotcall', e.getExceptionField() + '');
                }
                
            }
        }
    }
    
    @IsTest
    static void insertAsUserSObjectMissingParameters() {
        try {
            ESAPI.accessController().insertAsUser(new Lead(), new List<String>{});
            System.assert(false, 'Exception expected');
        } catch (SFDCAccessController.AccessControlDmlException ex) {
            System.assertEquals('null or empty parameter', ex.getMessage());
        }
        
        try {
            ESAPI.accessController().insertAsUser(new Lead(), new List<Schema.SObjectField>{});
            System.assert(false, 'Exception expected');
        } catch (SFDCAccessController.AccessControlDmlException ex) {
            System.assertEquals('null or empty parameter', ex.getMessage());
        }
    }
    
    @IsTest
    static void insertAsUserMapMissingParameters() {
        try {
            ESAPI.accessController().insertAsUser(new List<Lead>{}, new List<String>{});
            System.assert(false, 'Exception expected');
        } catch (SFDCAccessController.AccessControlDmlException ex) {
            System.assertEquals('null or empty parameter', ex.getMessage());
        }
        
        try {
            ESAPI.accessController().insertAsUser(new List<Lead>{}, new List<Schema.SObjectField>{});
            System.assert(false, 'Exception expected');
        } catch (SFDCAccessController.AccessControlDmlException ex) {
            System.assertEquals('null or empty parameter', ex.getMessage());
        }
    }
    
    //#endregion
    
    //#region Update
    // No access to field on sObject update
    @isTest
    static void runasProfileNoUpdatesObjectField() {
        runasProfileNoUpdatesObjectField_Internal(false, false);
    }
    
    @isTest
    static void runasProfileNoUpdatesObjectsField() {
        runasProfileNoUpdatesObjectField_Internal(true, false);
    }
    
    @isTest
    static void runasProfileNoUpdatesObjectField_asSObjectField() {
        runasProfileNoUpdatesObjectField_Internal(false, true);
    }
    
    @isTest
    static void runasProfileNoUpdatesObjectsField_asSObjectField() {
        runasProfileNoUpdatesObjectField_Internal(true, true);
    }
    
    static void runasProfileNoUpdatesObjectField_Internal(boolean asCollection, boolean asSObjectField) {
        
        FieldPermissions doNotCallFieldPermission = new FieldPermissions(SobjectType ='Lead',
                                                                         Field = 'Lead.DoNotCall',
                                                                         PermissionsRead = true,
                                                                         PermissionsEdit = false
                                                                        );  
        
        boolean createReadWriteFieldPermissions = true;
        User u = testReadOnlyProfileUser(true, contactObjectCreateEditReadPermission, createReadWriteFieldPermissions, new List<FieldPermissions>{doNotCallFieldPermission} );
        
        System.runAs(u) {
            try {
                Lead c = new Lead();
                c.LastName = 'ESAPI Test4 Spu8UY&thuCrUzAPa2ASTaC7rA$Ra3';
                c.DoNotCall = true;
                c.Status = 'Open';
                c.Email = 'xyz@gmail.com';
                c.Company = 'JumboInter';
                insert c;
                
                System.assert(SObjectType.Lead.createable);
                System.assert(!SObjectType.Lead.fields.DoNotCall.isCreateable(), 'The Lead.DoNotCall field should not be Createable. Just Readable');
                System.assert(!SObjectType.Lead.fields.DoNotCall.isUpdateable()); 
                //System.assert(SObjectType.Lead.fields.Description.isCreateable());
                //System.assert(SObjectType.Lead.fields.Description.isUpdateable());
                 
                
                ESAPI.accessController().setOperationMode(SFDCAccessController.OperationMode.ALL_OR_NONE);
                ESAPI.accessController().setSharingMode(SFDCAccessController.SharingMode.WITH);
                
                fieldsToCheck.add('DoNotCall');
                
                if(asSObjectField) {
                    List<Schema.SObjectField> schemaSObjectFields = schemaSObjectFields(Schema.Lead.getSobjectType(), fieldsToCheck);
                    
                    if(asCollection) {
                        ESAPI.accessController().updateAsUser(new Map<Id, Lead>{c.Id => c}, schemaSObjectFields);
                    } else {
                        ESAPI.accessController().updateAsUser(c, schemaSObjectFields);
                    }
                } else {
                    if(asCollection) {
                        ESAPI.accessController().updateAsUser(new Map<Id, Lead>{c.Id => c}, fieldsToCheck);
                    } else {
                        ESAPI.accessController().updateAsUser(c, fieldsToCheck);
                    }
                }
                
                System.assert(false, 'Should never get here. Not expected to have permission to update the Lead.DoNotCall field');
            }  catch (SFDCAccessControlException e) {
                // should fail - so all good
                string errStr = 'Access control violation - Type: ' + e.getExceptionType() + ' Reason: '  
                    + e.getExceptionReason() + ' Object: ' + e.getExceptionObject() + ' Field: '  
                    + e.getExceptionField() + ' Text: ' + e.getText(); 
                
                System.assertEquals(SFDCAccessControlException.ExceptionReason.NO_UPDATE, e.getExceptionReason());
                System.assertEquals('Access Violation', e.getText());
                System.assertEquals(SFDCAccessControlException.ExceptionType.FIELD_ACCESS_VIOLATION, e.getExceptionType());
                System.assertEquals('Lead', e.getExceptionObject() + '');
                
                if(asSObjectField) {
                    System.assertEquals('DoNotCall', e.getExceptionField() + '', 'Expected to have no access to the Lead.DoNotCall field');
                } else {
                    System.assertEquals('donotcall', e.getExceptionField() + '', 'Expected to have no access to the Lead.DoNotCall field');
                }
                
            }
        }
    }
    
    @isTest
    static void updateSObjectDoesNotExist() {
        updateSObjectDoesNotExist_Internal(false, false);
    }
    
    @isTest
    static void updateSObjectsDoesNotExist() {
        updateSObjectDoesNotExist_Internal(true, false);
    }
    
    @isTest
    static void updateSObjectDoesNotExist_sObjectField() {
        updateSObjectDoesNotExist_Internal(false, true);
    }
    
    @isTest
    static void updateSObjectsDoesNotExist_sObjectField() {
        updateSObjectDoesNotExist_Internal(true, true);
    }
    
    static void updateSObjectDoesNotExist_Internal(boolean asCollection, boolean sObjectField) {
        try {
            Lead c = new Lead();
            // Lead should not exist with this ID.
            c.Id = '00Q000000000000';
            c.LastName = 'ESAPI Test4 Spu8UY&thuCrUzAPa2ASTaC7rA$Ra3';
            c.Status = 'Open';
            c.Email = 'xyz@gmail.com';
            c.Company = 'AllisterInternational';
            System.assert(SObjectType.Lead.createable);
            
            ESAPI.accessController().setOperationMode(SFDCAccessController.OperationMode.ALL_OR_NONE);
            ESAPI.accessController().setSharingMode(SFDCAccessController.SharingMode.WITH);
            
            if(sObjectField) {
                if(asCollection) {
                    ESAPI.accessController().updateAsUser(new Map<Id, Lead>{c.Id => c}, new List<Schema.SObjectField>{Schema.Lead.Fields.LastName, Schema.Lead.Fields.FirstName});
                } else {
                    ESAPI.accessController().updateAsUser(c, new List<Schema.SObjectField>{Schema.Lead.Fields.LastName, Schema.Lead.Fields.FirstName});
                }
            } else {
                if(asCollection) {
                    ESAPI.accessController().updateAsUser(new Map<Id, Lead>{c.Id => c}, new List<String>{'LastName','FirstName'});
                } else {
                    ESAPI.accessController().updateAsUser(c, new List<String>{'LastName','FirstName'});
                }
            }
            
            System.assert(false, 'Should never get here. Not expected find existing sObject');
        }  catch (SFDCAccessControlException e) {
            // should fail - so all good
            
            System.assertEquals(SFDCAccessControlException.ExceptionReason.GENERIC, e.getExceptionReason());
            
            System.assertEquals(SFDCAccessControlException.ExceptionType.NO_RECORD_FOUND, e.getExceptionType());
            System.assertEquals('Lead', e.getExceptionObject() + '');
            
            if(asCollection) {
                // At least some record[s]?
                System.assertEquals('At least some record do not exist or are not shared with current user', e.getText());
            } else {
                System.assertEquals('Record does not exist or not shared with current user', e.getText());
            }
        }
    }
    
    @IsTest
    static void updateAsUserSObjectMissingParameters() {
        try {
            ESAPI.accessController().updateAsUser(new Lead(), new List<String>{});
            System.assert(false, 'Exception expected');
        } catch (SFDCAccessController.AccessControlDmlException ex) {
            System.assertEquals('null or empty parameter', ex.getMessage());
        }
        
        try {
            ESAPI.accessController().updateAsUser(new Lead(), new List<Schema.SObjectField>{});
            System.assert(false, 'Exception expected');
        } catch (SFDCAccessController.AccessControlDmlException ex) {
            System.assertEquals('null or empty parameter', ex.getMessage());
        }
    }
    
    @IsTest
    static void updateAsUserMapMissingParameters() {
        try {
            ESAPI.accessController().updateAsUser(new Map<Id, Lead>{}, new List<String>{});
            System.assert(false, 'Exception expected');
        } catch (SFDCAccessController.AccessControlDmlException ex) {
            System.assertEquals('null or empty parameter', ex.getMessage());
        }
        
        try {
            ESAPI.accessController().updateAsUser(new Map<Id, Lead>{}, new List<Schema.SObjectField>{});
            System.assert(false, 'Exception expected');
        } catch (SFDCAccessController.AccessControlDmlException ex) {
            System.assertEquals('null or empty parameter', ex.getMessage());
        }
    }
    
    // No update access on the sObject
    @isTest
    static void runasProfileNoUpdatesObject() {
        runasProfileNoUpdatesObject_Internal(false, false);
    }
    
    @isTest
    static void runasProfileNoUpdatesObjects() {
        runasProfileNoUpdatesObject_Internal(true, false);
    }
    
    @isTest
    static void runasProfileNoUpdatesObject_sObjectField() {
        runasProfileNoUpdatesObject_Internal(false, true);
    }
    
    @isTest
    static void runasProfileNoUpdatesObjects_sObjectField() {
        runasProfileNoUpdatesObject_Internal(true, true);
    }
    
    static void runasProfileNoUpdatesObject_Internal(boolean asCollection, boolean sObjectField) {
        User u = testReadOnlyProfileUser(false);
        
        System.runAs(u) {
            try {
                Lead c = new Lead();
                c.LastName = 'ESAPI Test4 Spu8UY&thuCrUzAPa2ASTaC7rA$Ra3';
                c.Email = 'xyz@gmail.com';
                c.Status = 'Open';
                c.Company = 'AvenueForex';
                insert c;
                
                ESAPI.accessController().setOperationMode(SFDCAccessController.OperationMode.ALL_OR_NONE);
                ESAPI.accessController().setSharingMode(SFDCAccessController.SharingMode.WITH);
                
                if(sObjectField) {
                    if(asCollection) {
                        ESAPI.accessController().updateAsUser(c, new List<Schema.SObjectField>{Schema.Lead.Fields.LastName,Schema.Lead.Fields.Email,Schema.Lead.Fields.Status});
                    } else {
                        ESAPI.accessController().updateAsUser(new Map<Id, Lead>{c.Id => c}, new List<Schema.SObjectField>{Schema.Lead.Fields.LastName,Schema.Lead.Fields.Email,Schema.Lead.Fields.Status});
                    }
                } else {
                    if(asCollection) {
                        ESAPI.accessController().updateAsUser(c, new List<String>{'LastName','Email','Status'});
                    } else {
                        ESAPI.accessController().updateAsUser(new Map<Id, Lead>{c.Id => c}, new List<String>{'LastName','Email','Status'});
                    }
                }
                
                System.assert(false, 'Should never get here. Not expected to have update access for Lead');
            }  catch (SFDCAccessControlException e) {
                // should fail - so all good
                string errStr = 'Access control violation - Type: ' + e.getExceptionType() + ' Reason: '  
                    + e.getExceptionReason() + ' Object: ' + e.getExceptionObject() + ' Field: '  
                    + e.getExceptionField() + ' Text: ' + e.getText(); 
                
                System.assertEquals(SFDCAccessControlException.ExceptionReason.NO_UPDATE, e.getExceptionReason());
                System.assertEquals('Access Violation', e.getText());
                System.assertEquals(SFDCAccessControlException.ExceptionType.OBJECT_ACCESS_VIOLATION, e.getExceptionType());
            }
        }
    }
    //#endregion
    
    //#region Delete
    
    @IsTest
    static void noDeleteSObject() {
        User u = testReadOnlyProfileUser(false);
        
        System.runAs(u) {
            try {
                ESAPI.accessController().deleteAsUser(new Lead());
                System.assert(false, 'Exception expected');
            } catch (SFDCAccessControlException e) {
                System.assertEquals(SFDCAccessControlException.ExceptionReason.NO_DELETE, e.getExceptionReason());
                System.assertEquals('Access Violation', e.getText());
                System.assertEquals(SFDCAccessControlException.ExceptionType.OBJECT_ACCESS_VIOLATION, e.getExceptionType());
            }
        }
    }
    
    @IsTest
    static void noDeleteSObjects() {
        User u = testReadOnlyProfileUser(false);
        
        System.runAs(u) {
            try {
                ESAPI.accessController().deleteAsUser(new List<Lead>{new Lead()});
                System.assert(false, 'Exception expected');
            } catch (SFDCAccessControlException e) {
                System.assertEquals(SFDCAccessControlException.ExceptionReason.NO_DELETE, e.getExceptionReason());
                System.assertEquals('Access Violation', e.getText());
                System.assertEquals(SFDCAccessControlException.ExceptionType.OBJECT_ACCESS_VIOLATION, e.getExceptionType());
            }
        }
    }
    
    @IsTest
    static void deleteAsUserMissingParameters() {
        
        try {
            Lead c = null;
            ESAPI.accessController().deleteAsUser(c);
            System.assert(false, 'Exception expected');
        } catch (SFDCAccessController.AccessControlDmlException ex) {
            System.assertEquals('null parameter', ex.getMessage());
        }
        
        try {
            ESAPI.accessController().deleteAsUser(new List<Lead>{});
            System.assert(false, 'Exception expected');
        } catch (SFDCAccessController.AccessControlDmlException ex) {
            System.assertEquals('null parameter', ex.getMessage());
        }
    }
    
    //#endregion
    
    //#region isAuthorizedToView
    @IsTest
    static void runasProfileNotAuthorizedToViewSObject() {
        User u = testReadOnlyProfileUser(true);
        
        System.runAs(u) {
            ESAPI.accessController().setOperationMode(SFDCAccessController.OperationMode.ALL_OR_NONE);
            ESAPI.accessController().setSharingMode(SFDCAccessController.SharingMode.WITH);
            
            Schema.SObjectType imageSObjectType = ((Id)'4YL000000000000').getsobjecttype(); //Schema.Image.getSobjectType()
            
            boolean isAccessible = ESAPI.accessController().isAuthorizedToView(imageSObjectType, new List<String>{'Name','OwnerId','ImageViewType','ImageTitle','ImageAlternateText','ImageUrl','IsActive','ImageClass','ImageClassObjectType','ContentDocumentId','CapturedAngle '});
            System.assert(!isAccessible, 'Not expecting to have access to view Image records');
            
            isAccessible = ESAPI.accessController().isAuthorizedToView(imageSObjectType, new List<Schema.SObjectField>{});
            System.assert(!isAccessible, 'Not expecting to have access to view Image records');
        }
    }
    
    @IsTest
    static void runasProfileNotAuthorizedToViewSObjectField() {
        boolean createReadWriteFieldPermissions = true;
        User u = testReadOnlyProfileUser(true, contactObjectReadPermission, createReadWriteFieldPermissions, null);
        
        System.runAs(u) {
            ESAPI.accessController().setOperationMode(SFDCAccessController.OperationMode.ALL_OR_NONE);
            ESAPI.accessController().setSharingMode(SFDCAccessController.SharingMode.WITH);
            
            // Not expected to have access to the DoNotCall field
            fieldsToCheck.add('DoNotCall');
            System.assert(!SObjectType.Lead.fields.DoNotCall.isCreateable());
            System.assert(!SObjectType.Lead.fields.DoNotCall.isUpdateable()); 
            
            boolean isAccessible = ESAPI.accessController().isAuthorizedToView(Schema.Lead.getSobjectType(), fieldsToCheck);
            System.assert(!isAccessible, 'Not expecting to have access to view Lead DoNotCall fields');
            
            List<Schema.SObjectField> schemaSObjectFields = schemaSObjectFields(Schema.Lead.getSobjectType(), fieldsToCheck);
            isAccessible = ESAPI.accessController().isAuthorizedToView(Schema.Lead.getSobjectType(), schemaSObjectFields);
            System.assert(!isAccessible, 'Not expecting to have access to view Lead DoNotCall records');
        }
    }
    
    @IsTest
    static void runasProfileAuthorizedToViewSObjectField() {
        boolean createReadWriteFieldPermissions = true;
        User u = testReadOnlyProfileUser(true, contactObjectReadPermission, createReadWriteFieldPermissions, null);
        
        System.runAs(u) {
            ESAPI.accessController().setOperationMode(SFDCAccessController.OperationMode.ALL_OR_NONE);
            ESAPI.accessController().setSharingMode(SFDCAccessController.SharingMode.WITH);
            
            boolean isAccessible = ESAPI.accessController().isAuthorizedToView(Schema.Lead.getSobjectType(), fieldsToCheck);
            System.assert(isAccessible, 'Expecting to have access to view Lead fields');
            
            List<Schema.SObjectField> schemaSObjectFields = schemaSObjectFields(Schema.Lead.getSobjectType(), fieldsToCheck);
            isAccessible = ESAPI.accessController().isAuthorizedToView(Schema.Lead.getSobjectType(), schemaSObjectFields);
            System.assert(isAccessible, 'Expecting to have access to view Lead DoNotCall records');
        }
    }
    
    @IsTest
    static void isAuthorizedToViewNonexistentField() {
        try {
            boolean isAccessible = ESAPI.accessController().isAuthorizedToView(Schema.Lead.getSobjectType(), new List<String>{'Name','FooBarFieldDoesNotExist'});
            System.assert(false, 'Exception expected');
        } catch (SFDCAccessControlException e) {
            System.assertEquals(SFDCAccessControlException.ExceptionReason.GENERIC, e.getExceptionReason());
            System.assertEquals('Field not found', e.getText());
            System.assertEquals(SFDCAccessControlException.ExceptionType.FIELD_NOT_FOUND, e.getExceptionType());
        }
    }
    //#endregion
    
    //#region isAuthorizedToCreate
    @IsTest
    static void runasProfileNotAuthorizedToCreateSObject() {
        boolean createReadWriteFieldPermissions = true;
        User u = testReadOnlyProfileUser(true, contactObjectReadPermission, createReadWriteFieldPermissions, null);
        
        System.runAs(u) {
            ESAPI.accessController().setOperationMode(SFDCAccessController.OperationMode.ALL_OR_NONE);
            ESAPI.accessController().setSharingMode(SFDCAccessController.SharingMode.WITH);
            
            boolean isAccessible = ESAPI.accessController().isAuthorizedToCreate(Schema.Lead.getSobjectType(), fieldsToCheck);
            System.assert(!isAccessible, 'Not expecting to have access to Create Lead records');
            
            isAccessible = ESAPI.accessController().isAuthorizedToCreate(Schema.Lead.getSobjectType(), new List<Schema.SObjectField>{Schema.Lead.Fields.LastName});
            System.assert(!isAccessible, 'Not expecting to have access to Create Lead records');
        }
    }
    
    @IsTest
    static void runasProfileAuthorizedToCreateSObject() {
        boolean createReadWriteFieldPermissions = true;
        User u = testReadOnlyProfileUser(true, contactObjectCreateReadPermission, createReadWriteFieldPermissions, null);
        
        System.runAs(u) {
            ESAPI.accessController().setOperationMode(SFDCAccessController.OperationMode.ALL_OR_NONE);
            ESAPI.accessController().setSharingMode(SFDCAccessController.SharingMode.WITH);
            
            boolean isAccessible = ESAPI.accessController().isAuthorizedToCreate(Schema.Lead.getSobjectType(), fieldsToCheck);
            System.assert(isAccessible, 'Expecting to have access to Create Lead records');
            
            isAccessible = ESAPI.accessController().isAuthorizedToCreate(Schema.Lead.getSobjectType(), new List<Schema.SObjectField>{Schema.Lead.Fields.LastName});
            System.assert(isAccessible, 'Expecting to have access to Create Lead records');
        }
    }
    
    @IsTest
    static void runasProfileNotAuthorizedToCreateSObjectField() {
        boolean createReadWriteFieldPermissions = true;
        User u = testReadOnlyProfileUser(true, contactObjectCreateReadPermission, createReadWriteFieldPermissions, null);
        
        System.runAs(u) {
            ESAPI.accessController().setOperationMode(SFDCAccessController.OperationMode.ALL_OR_NONE);
            ESAPI.accessController().setSharingMode(SFDCAccessController.SharingMode.WITH);
            
            // Not expected to have access to the DoNotCall field
            fieldsToCheck.add('DoNotCall');
            System.assert(!SObjectType.Lead.fields.DoNotCall.isCreateable());
            System.assert(!SObjectType.Lead.fields.DoNotCall.isUpdateable()); 
            
            boolean isAccessible = ESAPI.accessController().isAuthorizedToCreate(Schema.Lead.getSobjectType(), fieldsToCheck);
            System.assert(!isAccessible, 'Not expecting to have access to Create Lead records with DoNotCall field');
            
            List<Schema.SObjectField> schemaSObjectFields = schemaSObjectFields(Schema.Lead.getSobjectType(), fieldsToCheck);
            isAccessible = ESAPI.accessController().isAuthorizedToCreate(Schema.Lead.getSobjectType(), schemaSObjectFields);
            System.assert(!isAccessible, 'Not expecting to have access to Create Lead records with DoNotCall field');
        }
    }
    
    @IsTest
    static void isAuthorizedToCreateNonexistentField() {
        try {
            boolean isAccessible = ESAPI.accessController().isAuthorizedToCreate(Schema.Lead.getSobjectType(), new List<String>{'FooBarFieldDoesNotExist'});
            System.assert(false, 'Exception expected as field does not exist');
        } catch (SFDCAccessControlException e) {
            System.assertEquals(SFDCAccessControlException.ExceptionReason.GENERIC, e.getExceptionReason());
            System.assertEquals('Field not found', e.getText());
            System.assertEquals(SFDCAccessControlException.ExceptionType.FIELD_NOT_FOUND, e.getExceptionType());
        }
    }
    //#endregion
    
    //#region isAuthorizedToUpdate
    @IsTest
    static void runasProfileNotAuthorizedToUpdateSObject() {
        boolean createReadWriteFieldPermissions = true;
        User u = testReadOnlyProfileUser(true, contactObjectReadPermission, createReadWriteFieldPermissions, null);
        
        System.runAs(u) {
            ESAPI.accessController().setOperationMode(SFDCAccessController.OperationMode.ALL_OR_NONE);
            ESAPI.accessController().setSharingMode(SFDCAccessController.SharingMode.WITH);
            
            boolean isAccessible = ESAPI.accessController().isAuthorizedToUpdate(Schema.Lead.getSobjectType(), fieldsToCheck);
            System.assert(!isAccessible, 'Not expecting to have access to Update Lead records');
            
            List<Schema.SObjectField> sObjectFieldsToCheck = schemaSObjectFields(Schema.Lead.getSobjectType(), fieldsToCheck);
            isAccessible = ESAPI.accessController().isAuthorizedToUpdate(Schema.Lead.getSobjectType(), sObjectFieldsToCheck);
            System.assert(!isAccessible, 'Not expecting to have access to Update Lead records');
        }
    }
    
    @IsTest
    static void runasProfileAuthorizedToUpdateSObject() {
        boolean createReadWriteFieldPermissions = true;
        User u = testReadOnlyProfileUser(true, contactObjectEditReadPermission, createReadWriteFieldPermissions, null);
        
        System.runAs(u) {
            ESAPI.accessController().setOperationMode(SFDCAccessController.OperationMode.ALL_OR_NONE);
            ESAPI.accessController().setSharingMode(SFDCAccessController.SharingMode.WITH);
            
            boolean isAccessible = ESAPI.accessController().isAuthorizedToUpdate(Schema.Lead.getSobjectType(), fieldsToCheck);
            System.assert(isAccessible, 'Expecting to have access to Update Lead records');
            
            List<Schema.SObjectField> sObjectFieldsToCheck = schemaSObjectFields(Schema.Lead.getSobjectType(), fieldsToCheck);
            isAccessible = ESAPI.accessController().isAuthorizedToUpdate(Schema.Lead.getSobjectType(), sObjectFieldsToCheck);
            System.assert(isAccessible, 'Expecting to have access to Update Lead records');
        }
    }
    
    @IsTest
    static void runasProfileNotAuthorizedToUpdateSObjectField() {
        boolean createReadWriteFieldPermissions = true;
        User u = testReadOnlyProfileUser(true, contactObjectEditReadPermission, createReadWriteFieldPermissions, null);
        
        System.runAs(u) {
            ESAPI.accessController().setOperationMode(SFDCAccessController.OperationMode.ALL_OR_NONE);
            ESAPI.accessController().setSharingMode(SFDCAccessController.SharingMode.WITH);
            
            // Not expected to have access to the DoNotCall field
            fieldsToCheck.add('DoNotCall');
            System.assert(!SObjectType.Lead.fields.DoNotCall.isCreateable());
            System.assert(!SObjectType.Lead.fields.DoNotCall.isUpdateable()); 
            
            boolean isAccessible = ESAPI.accessController().isAuthorizedToUpdate(Schema.Lead.getSobjectType(), fieldsToCheck);
            System.assert(!isAccessible, 'Not expecting to have access to Update Lead DoNotCall field');
            
            List<Schema.SObjectField> sObjectFieldsToCheck = schemaSObjectFields(Schema.Lead.getSobjectType(), fieldsToCheck);
            isAccessible = ESAPI.accessController().isAuthorizedToUpdate(Schema.Lead.getSobjectType(), sObjectFieldsToCheck);
            System.assert(!isAccessible, 'Not expecting to have access to Update Lead DoNotCall field');
        }
    }
    
    @IsTest
    static void isAuthorizedToUpdateNonexistentField() {
        try {
            boolean isAccessible = ESAPI.accessController().isAuthorizedToUpdate(Schema.Lead.getSobjectType(), new List<String>{'FooBarFieldDoesNotExist'});
            System.assert(false, 'Exception expected as field does not exist');
        } catch (SFDCAccessControlException e) {
            System.assertEquals(SFDCAccessControlException.ExceptionReason.GENERIC, e.getExceptionReason());
            System.assertEquals('Field not found', e.getText());
            System.assertEquals(SFDCAccessControlException.ExceptionType.FIELD_NOT_FOUND, e.getExceptionType());
        }
    }
    //#endregion
    
    //#region isAuthorizedToDelete
    @IsTest
    static void runasProfileNotAuthorizedToDeleteSObject() {
        boolean createReadWriteFieldPermissions = false;
        User u = testReadOnlyProfileUser(true, contactObjectReadPermission, createReadWriteFieldPermissions, null);
        
        System.runAs(u) {
            ESAPI.accessController().setOperationMode(SFDCAccessController.OperationMode.ALL_OR_NONE);
            ESAPI.accessController().setSharingMode(SFDCAccessController.SharingMode.WITH);
            
            boolean isAccessible = ESAPI.accessController().isAuthorizedToDelete(Schema.Lead.getSobjectType());
            System.assert(!isAccessible, 'Not expecting to have access to Delete Lead records');
        }
    }
    
    @IsTest
    static void runasProfileAuthorizedToDeleteSObject() {
        boolean createReadWriteFieldPermissions = false;
        User u = testReadOnlyProfileUser(true, contactObjectDeleteEditReadPermission, createReadWriteFieldPermissions, null);
        
        System.runAs(u) {
            ESAPI.accessController().setOperationMode(SFDCAccessController.OperationMode.ALL_OR_NONE);
            ESAPI.accessController().setSharingMode(SFDCAccessController.SharingMode.WITH);
            
            boolean isAccessible = ESAPI.accessController().isAuthorizedToDelete(Schema.Lead.getSobjectType());
            System.assert(isAccessible, 'Expecting to have access to Delete Lead records');
        }
    }
    //#endregion
    
    static testMethod void testReturnedObjects() {
        /* test return object and id with strings */
        Lead tmp;
        Lead tmp2;
        Lead tmp3;
        Lead tmp4;
        Lead c1 = new Lead();
        c1.LastName = 'ESAPI Test Spu8UY&thuCrUzAPa2ASTaC7rA$Ra3 c1'; // We add this long random to make sure we will not conflict with any real last name 
        c1.Email = 'xyz@gmail.com';
        c1.Status = 'Open';c1.Company = 'TendulkarInter';
        tmp = (Lead)ESAPI.accessController().insertAsUser(c1, new List<String>{'LastName','Email','Status','Company'});
        tmp2 = [select LastName, Id, Email, Status from Lead where LastName = 'ESAPI Test Spu8UY&thuCrUzAPa2ASTaC7rA$Ra3 c1' limit 1];
        tmp3 = [select LastName, Id, Email, Status from Lead where Id =: tmp.Id limit 1];
        
        System.assert(tmp != null, 'insertAsUser returned null');
        System.assert(tmp2 != null, 'select with LastName after insertAsUser returned null');
        System.assert(tmp3 != null, 'select with tmp.id after insertAsUser returned null');
        
        System.assert(tmp.id == tmp2.id, 'select with LastName after insertAsUser returned id which is not equal to id from returned object');
        System.assert(tmp.id == tmp3.id, 'select with tmp.id after insertAsUser returned id which is not equal to id from returned object');
        
        tmp.LastName = 'ESAPI Test Spu8UY&thuCrUzAPa2ASTaC7rA$Ra3 c1 updated';
        tmp4 = (Lead)ESAPI.accessController().updateAsUser(tmp, new List<String>{'LastName'});
        tmp3 = [select LastName, Id from Lead where Id =: tmp.Id limit 1];
        
        System.assert(tmp4 != null, 'updateAsUser returned null');
        System.assert(tmp3 != null, 'select with tmp.id after updateAsUser returned null');
        
        System.assert(tmp.id == tmp4.id, 'id from returned object after updateAsUser is not equal to id from original returned object from insertAsUser');
        System.assert(tmp.id == tmp3.id, 'id from select with id from original reurned object after insertAsUser, is not equal to id from original returned object from insertAsUser');
        
        System.assert(tmp.LastName == tmp3.LastName, 'c1.LastName == tmp3.LastName');
        System.assert(tmp.LastName == tmp4.LastName, 'c1.LastName == tmp4.LastName');
        
        /* test return object and id with Schema.SObjectField */
        c1 = new Lead();
        c1.LastName = 'ESAPI Test Spu8UY&thuCrUzAPa2ASTaC7rA$Ra3 c1'; // We add this long random to make sure we will not conflict with any real last name 
        c1.Company = 'JikkaInter';
        tmp = (Lead)ESAPI.accessController().insertAsUser(c1, new List<Schema.SObjectField>{Lead.LastName,Lead.Company});
        tmp2 = [select LastName, Id from Lead where LastName = 'ESAPI Test Spu8UY&thuCrUzAPa2ASTaC7rA$Ra3 c1' limit 1];
        tmp3 = [select LastName, Id from Lead where Id =: tmp.Id limit 1];
        
        System.assert(tmp != null, 'insertAsUser returned null');
        System.assert(tmp2 != null, 'select with LastName after insertAsUser returned null');
        System.assert(tmp3 != null, 'select with tmp.id after insertAsUser returned null');
        
        System.assert(tmp.id == tmp2.id, 'select with LastName after insertAsUser returned id which is not equal to id from returned object');
        System.assert(tmp.id == tmp3.id, 'select with tmp.id after insertAsUser returned id which is not equal to id from returned object');
        
        tmp.LastName = 'ESAPI Test Spu8UY&thuCrUzAPa2ASTaC7rA$Ra3 c1 updated';
        tmp4 = (Lead)ESAPI.accessController().updateAsUser(tmp, new List<Schema.SObjectField>{Lead.LastName});
        tmp3 = [select LastName, Id from Lead where Id =: tmp.Id limit 1];
        
        System.assert(tmp4 != null, 'updateAsUser returned null');
        System.assert(tmp3 != null, 'select with tmp.id after updateAsUser returned null');
        
        System.assert(tmp.id == tmp4.id, 'id from returned object after updateAsUser is not equal to id from original returned object from insertAsUser');
        System.assert(tmp.id == tmp3.id, 'id from select with id from original reurned object after insertAsUser, is not equal to id from original returned object from insertAsUser');
        
        System.assert(tmp.LastName == tmp3.LastName, 'c1.LastName == tmp3.LastName');
        System.assert(tmp.LastName == tmp4.LastName, 'c1.LastName == tmp4.LastName');
    }
    
    static testMethod void testAccessControlArray() {
        String errStr;
        
        try {
            // test with sharing
            Lead c1 = new Lead();
            c1.LastName = 'ESAPI TestArray1 Spu8UY&thuCrUzAPa2ASTaC7rA$Ra3'; // We add this long random to make sure we will not conflict with any real last name
            c1.Company = 'BajajInter';
            Lead c2 = new Lead();
            c2.LastName = 'ESAPI TestArray2 Spu8UY&thuCrUzAPa2ASTaC7rA$Ra3'; // We add this long random to make sure we will not conflict with any real last name
            c2.Company = 'AllianzInter';
            Lead [] arr = new Lead[]{c1, c2};
                Database.SaveResult [] results;
            
            ESAPI.accessController().setOperationMode(SFDCAccessController.OperationMode.ALL_OR_NONE);
            ESAPI.accessController().setArrayOperationMode(SFDCAccessController.OperationMode.ALL_OR_NONE);
            ESAPI.accessController().setSharingMode(SFDCAccessController.SharingMode.WITH);
            results = ESAPI.accessController().insertAsUser(arr, new List<String>{'LastName','Company'}).getResults();
            results = ESAPI.accessController().insertAsUser(arr, new List<Schema.SObjectField>{Lead.LastName,Lead.FirstName,Lead.Company}).getResults();
            
            System.assert(results.size() == 2, 'Could not insert two objects into db #1');
            System.assert(results[0].isSuccess() == true, 'Could not insert first object into db #1 [0] - ' + results[0].getErrors());
            System.assert(results[1].isSuccess() == true, 'Could not insert second object into db #1 [1] - ' + results[0].getErrors());
            
            arr = [select LastName,id from Lead where Id=:results[0].getId() or Id=:results[1].getId()];
            
            System.assert(arr.size() == 2, 'Could not get two objects from db #1');
            
            arr[0].LastName = 'ESAPI TestArray3 Spu8UY&thuCrUzAPa2ASTaC7rA$Ra3 updated';
            arr[1].LastName = 'ESAPI TestArray4 Spu8UY&thuCrUzAPa2ASTaC7rA$Ra3 updated';
            
            ESAPI.accessController().updateAsUser(new Map<ID, Lead>(arr), new List<String>{'LastName'});
            ESAPI.accessController().updateAsUser(new Map<ID, Lead>(arr), new List<Schema.SObjectField>{Lead.LastName});
            ESAPI.accessController().deleteAsUser(arr);
            
            // test without sharing
            c1 = new Lead();
            c1.LastName = 'ESAPI TestArray32 Spu8UY&thuCrUzAPa2ASTaC7rA$Ra3'; // We add this long random to make sure we will not conflict with any real last name
            c1.Company = 'SehwagInter';
            c2 = new Lead();
            c2.Company = 'GambhirInter';
            c2.LastName = 'ESAPI TestArray42 Spu8UY&thuCrUzAPa2ASTaC7rA$Ra3'; // We add this long random to make sure we will not conflict with any real last name
            arr = new Lead[]{c1, c2};
                
                ESAPI.accessController().setOperationMode(SFDCAccessController.OperationMode.BEST_EFFORT);
            ESAPI.accessController().setArrayOperationMode(SFDCAccessController.OperationMode.BEST_EFFORT);
            ESAPI.accessController().setSharingMode(SFDCAccessController.SharingMode.WITHOUT);
            results = ESAPI.accessController().insertAsUser(arr, new List<String>{'LastName','Company'}).getResults();
            
            arr = [select LastName,id from Lead where Id=:results[0].getId() or Id=:results[1].getId()];
            
            System.assert(arr.size() == 2, 'Could not get two objects from db #2');
            
            arr[0].LastName = 'ESAPI TestArray34 Spu8UY&thuCrUzAPa2ASTaC7rA$Ra3 updated';
            arr[1].LastName = 'ESAPI TestArray47 Spu8UY&thuCrUzAPa2ASTaC7rA$Ra3 updated';
            
            ESAPI.accessController().updateAsUser(new Map<ID, Lead>(arr), new List<String>{'LastName'});
            ESAPI.accessController().deleteAsUser(arr);
            
            // test inherit sharing
            c1 = new Lead();
            c1.LastName = 'ESAPI TestArray59 Spu8UY&thuCrUzAPa2ASTaC7rA$Ra3'; // We add this long random to make sure we will not conflict with any real last name
            c1.Company = 'UshaInter';
            c2 = new Lead();
            c2.Company = 'JackieInter';
            c2.LastName = 'ESAPI TestArray63 Spu8UY&thuCrUzAPa2ASTaC7rA$Ra3'; // We add this long random to make sure we will not conflict with any real last name
            arr = new Lead[]{c1, c2};
                
                ESAPI.accessController().setOperationMode(SFDCAccessController.OperationMode.BEST_EFFORT);
            ESAPI.accessController().setArrayOperationMode(SFDCAccessController.OperationMode.BEST_EFFORT);
            ESAPI.accessController().setSharingMode(SFDCAccessController.SharingMode.INHERIT);
            results = ESAPI.accessController().insertAsUser(arr, new List<String>{'LastName','Company'}).getResults();
            
            arr = [select LastName,id from Lead where Id=:results[0].getId() or Id=:results[1].getId()];
            
            System.assert(arr.size() == 2, 'Could not get two objects from db #3');
            
            arr[0].LastName = 'ESAPI TestArray52 Spu8UY&thuCrUzAPa2ASTaC7rA$Ra3 updated';
            arr[1].LastName = 'ESAPI TestArray60 Spu8UY&thuCrUzAPa2ASTaC7rA$Ra3 updated';
            
            ESAPI.accessController().updateAsUser(new Map<ID, Lead>(arr), new List<String>{'LastName'});
            ESAPI.accessController().deleteAsUser(arr);
            
            // test results class
            c1 = new Lead();
            c1.LastName = 'ESAPI TestArray578 Spu8UY&thuCrUzAPa2ASTaC7rA$Ra3'; // We add this long random to make sure we will not conflict with any real last name
            c1.Company = 'JumbareInter';
            c2 = new Lead();
            c2.Company = 'ChiruInter';
            c2.LastName = 'ESAPI TestArray665 Spu8UY&thuCrUzAPa2ASTaC7rA$Ra3'; // We add this long random to make sure we will not conflict with any real last name
            arr = new Lead[]{c1, c2};
                
                ESAPI.accessController().setOperationMode(SFDCAccessController.OperationMode.ALL_OR_NONE);
            ESAPI.accessController().setArrayOperationMode(SFDCAccessController.OperationMode.ALL_OR_NONE);
            ESAPI.accessController().setSharingMode(SFDCAccessController.SharingMode.WITH);
            
            SFDCAccessControlResults.InsertResults insertResults;
            sObject [] insertedObjects;
            
            insertResults = ESAPI.accessController().insertAsUser(arr, new List<String>{'LastName','Company'});
            
            System.assert(insertResults.wasSuccessful() == true, 'insertResults.wasSuccessful() == true');
            
            results = insertResults.getResults();
            System.assert(results.size() == 2, 'results.size() == 2');
            
            insertedObjects = insertResults.getInsertedObjects();
            System.assert(insertedObjects.size() == 2, 'insertedObjects.size() == 2');
            System.assert(insertedObjects[0].Id == results[0].getId(), 'insertedObjects[0].Id == results[0].getId()');
            System.assert(insertedObjects[1].Id == results[1].getId(), 'insertedObjects[1].Id == results[1].getId()');
            
            arr = [select LastName,id from Lead where Id=:results[0].getId() or Id=:results[1].getId()];
            
            System.assert(arr.size() == 2, 'Could not get two objects from db #3');
            
            arr[0].LastName = 'ESAPI TestArray521 Spu8UY&thuCrUzAPa2ASTaC7rA$Ra3 updated';
            arr[1].LastName = 'ESAPI TestArray656 Spu8UY&thuCrUzAPa2ASTaC7rA$Ra3 updated';
            
            SFDCAccessControlResults.UpdateResults updateResults;
            sObject [] updatedObjects;
            
            updateResults = ESAPI.accessController().updateAsUser(new Map<ID, Lead>(arr), new List<String>{'LastName'});
            
            System.assert(updateResults.wasSuccessful() == true, 'updateResults.wasSuccessful() == true');
            
            results = updateResults.getResults();
            System.assert(results.size() == 2, 'results.size() == 2');
            
            updatedObjects = updateResults.getUpdatedObjects();
            System.assert(updatedObjects.size() == 2, 'updatedObjects.size() == 2');
            System.assert(updatedObjects[0].Id == results[0].getId(), 'updatedObjects[0].Id == results[0].getId()');
            System.assert(updatedObjects[1].Id == results[1].getId(), 'updatedObjects[1].Id == results[1].getId()');
            
            SFDCAccessControlResults.DeleteResults deleteResults;
            deleteResults = ESAPI.accessController().deleteAsUser(arr);
            
            System.assert(deleteResults.wasSuccessful() == true, 'deleteResults.wasSuccessful() == true');
            
            Database.DeleteResult [] delResults = deleteResults.getResults();
            System.assert(delResults.size() == 2, 'delResults.size() == 2');
            
        } catch (SFDCAccessControlException e) {
            errStr = 'Access control violation - Type: ' + e.getExceptionType() + ' Reason: '  
                + e.getExceptionReason() + ' Object: ' + e.getExceptionObject() + ' Field: '  
                + e.getExceptionField() + ' Text: ' + e.getText(); 
        }
    }
    
    static testMethod void testAccessControlConstructor() {
        String errStr;
        
        try {
            SFDCAccessController ac = new SFDCAccessController(SFDCAccessController.SharingMode.WITHOUT, SFDCAccessController.OperationMode.ALL_OR_NONE, SFDCAccessController.OperationMode.ALL_OR_NONE);
        } catch (SFDCAccessControlException e) {
            errStr = 'Access control violation - Type: ' + e.getExceptionType() + ' Reason: '  
                + e.getExceptionReason() + ' Object: ' + e.getExceptionObject() + ' Field: '  
                + e.getExceptionField() + ' Text: ' + e.getText(); 
        }
    }
    
   static testMethod void testLimits() {
        /* This test is to confirm the new functions we added (insertAsUser and updateAsUser) 
           that use Schema.SObjectField indded solve the fields limiters issue. (fields has a limit of 10 calls)
           Now that we removed this limit, we should be able to call these functions until we hit the next type of
           limiter, this is likely to be DML operations which are capped at 100. This is why we are testing up to 100 */
           
        Integer max = 100;
        
        for (Integer i = 0; i < max; i++) {
            Lead leadRecord = new Lead(
                LastName = 'ESAPI Test Spu8UY&thuCrUzAPa2ASTaC7rA$Ra3 c Limits '+i,
                Status = 'Open',
                Email='thuCrUzAPa2ASTalimits'+i+'@thuCrUzAPa2ASTaC7rA.com',
                Company = 'KumbleInter'
            );
            ESAPI.accessController().insertAsUser(leadRecord, new List<Schema.SObjectField>{Lead.LastName, Lead.Status, Lead.Email,Lead.Company});
        }
        
        Lead [] arr = [SELECT LastName, Status, Email, Id FROM Lead WHERE LastName LIKE '%c Limits%'];
        
        System.assert(arr.size() == max, 'testLimits');
    }
    
    private static User testReadOnlyProfileUser(boolean insertRecord) {
        return testReadOnlyProfileUser(false, null, false, null);
    }
    
    private static User testReadOnlyProfileUser(boolean insertRecord, ObjectPermissions contactObjectPermission, boolean createReadWriteFieldPermissions, List<FieldPermissions> additonalFieldPerms) {
        // Built in System profile
        Profile readOnlyProfileId = [SELECT Id FROM Profile WHERE Name='Read Only'];
        
        User u = new User(Alias = 'standt', Email='standarduser@esapi.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = readOnlyProfileId.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@esapi.com');
        if(insertRecord) {
            insert u;
            
            PermissionSet ps = new PermissionSet(Label = 'mockPs', Name = 'mockPs');
            insert ps;
            
            if(contactObjectPermission != null) {
                contactObjectPermission.ParentId = ps.Id;
                insert contactObjectPermission;
            }
            
            if(createReadWriteFieldPermissions) {
                List<FieldPermissions> readWritePerms = createFieldPermissions(ps.Id, true, true);
                if(additonalFieldPerms != null) {
                    for(FieldPermissions fp : additonalFieldPerms) {
                        fp.ParentId = ps.Id;
                        readWritePerms.add(fp);
                    }
                }
                
                insert readWritePerms;
            }
            
            // Put the user with the ReadOnly profile into the new Permission Set to get any Object and Field permissions
            PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = ps.Id, AssigneeId = u.Id);
            insert psa; 
        }
        
        return u;
    }
    
    private static List<FieldPermissions> createFieldPermissions(Id permissionSetId, boolean read, boolean edit) {
        
        string sObjectType = 'Lead';
        
        List<string> readWriteFields = new List<String>{'Email'};
        
        List<FieldPermissions> fieldPerms = new List<FieldPermissions>();
        for(string fieldName : readWriteFields) {
            FieldPermissions contactFieldPermission = new FieldPermissions(SobjectType = sObjectType,
                                                                           Field = sObjectType + '.' + fieldName,
                                                                           ParentId = permissionSetId,
                                                                           PermissionsRead = read,
                                                                           PermissionsEdit = edit
                                                                          );
            fieldPerms.add(contactFieldPermission);
        }
        return fieldPerms;
    }
    
    // Convert from field names as string to Schema.SObjectFields
    private static List<Schema.SObjectField> schemaSObjectFields(Schema.SObjectType someType, List<string> fields) {
        List<Schema.SObjectField> schemaFields = new List<Schema.SObjectField>();
        
        Map<String, Schema.SObjectField> fieldMap = someType.getDescribe().fields.getMap();
        
        for(string fieldName : fields) {
            schemaFields.add(fieldMap.get(fieldName));
        }
        
        return schemaFields;
    }
}