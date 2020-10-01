/**
 * Underlying_Illness__c Trigger Handler Class -- with setup method so we get two execution contexts so we get two @future executions
 *
 * @author  Lawrence Coffin <lawrence.coffin@accenture.com>
 * @since   2020-04-27
 */
@IsTest
private class UnderlyingIllnessTriggerHandler_Test2 {

    /**
     * Setup the data
     * 
     * @future method should get executed after this method exits, so all the Case.IX_Underlying_Illness__c fields should get populated
     * and we can test secondary functionality like 'delete' trigger execution
     *
     * @author  Lawrence Coffin <lawrence.coffin@accenture.com>
     * @since   2020-04-27
     */
    @testSetup
    private static void setupData()
    {
        List<Underlying_Illness__c> uis = new List<Underlying_Illness__c>();

        //
        // Insert a Case
        //
        Case c = new Case();
        c.Subject = 'Test Case';
        insert c;
        
        c.Underlying_Illness__c = 'Yes';
        update c;

        //
        // Insert one Underlying Illness record
        //
        Underlying_Illness__c ui1 = new Underlying_Illness__c();
        ui1.Case__c = c.Id;
        ui1.Underlying_Illness_Specify__c = 'CARDIAC_DISEASE';
        ui1.Underlying_Illness_Description__c = 'Bad ticker!';
        uis.add(ui1);

        Underlying_Illness__c ui2 = new Underlying_Illness__c();
        ui2.Case__c = c.Id;
        ui2.Underlying_Illness_Specify__c = 'PREGNANT';
        ui2.Underlying_Illness_Description__c = 'Twins';
        ui2.Pregnancy_Detail__c = '22 wks';
        uis.add(ui2);
        
        Underlying_Illness__c ui3 = new Underlying_Illness__c();
        ui3.Case__c = c.Id;
        ui3.Underlying_Illness_Specify__c = 'OTHER';
        ui3.Underlying_Illness_Specify_Other__c = 'Asthma';
        ui3.Underlying_Illness_Description__c = 'Daily inhaler';
        uis.add(ui3);
        
        insert uis;

        // @future method should get executed after this method exits, so all the Case.IX_Underlying_Illness__c fields should get populated
    }

    /**
     * Test update of one of the records
     *
     * @author  Lawrence Coffin <lawrence.coffin@accenture.com>
     * @since   2020-04-27
     */
    private static testMethod void testUnderlyingIllness_Update()
    {
        List<Underlying_Illness__c> uis = [SELECT Id, Case__c FROM Underlying_Illness__c];
        System.assertNotEquals(null, uis);
        System.assertEquals(3, uis.size());

        //
        // Confirm the record was setup correctly and all the IX_* fields were populated
        //
        List<Case> cases = [SELECT Id,
                                   Underlying_Illness_Count__c,
                                   IX_Underlying_Illness_Specify__c,
                                   IX_Underlying_Illness_Specify_Other__c,
                                   IX_Underlying_Illness_Description__c,
                                   IX_Pregnancy_Detail__c
                            FROM Case
                            WHERE Id = :uis[0].Case__c];
        System.assertNotEquals(null, cases);
        System.assertEquals(1, cases.size());
        System.assertEquals(3, cases[0].Underlying_Illness_Count__c);
        System.assertEquals('CARDIAC_DISEASE;PREGNANT;OTHER', cases[0].IX_Underlying_Illness_Specify__c);
        System.assertEquals(';;Asthma', cases[0].IX_Underlying_Illness_Specify_Other__c);
        System.assertEquals('Bad ticker!;Twins;Daily inhaler', cases[0].IX_Underlying_Illness_Description__c);
        System.assertEquals(';22 wks;', cases[0].IX_Pregnancy_Detail__c);

        //
        // Now, the real test... try deleting one of the Underlying_Illness__c records
        //
        Test.startTest();

        uis[2].Underlying_Illness_Description__c = 'Uses inhaler twice daily';

        update uis[2];

        Test.stopTest(); // fire @future methods

        //
        // Confirm the case fields were updated correctly
        //
        cases = [SELECT Id,
                        Underlying_Illness_Count__c,
                        IX_Underlying_Illness_Specify__c,
                        IX_Underlying_Illness_Specify_Other__c,
                        IX_Underlying_Illness_Description__c,
                        IX_Pregnancy_Detail__c
                 FROM Case
                 WHERE Id = :uis[0].Case__c];
        System.assertNotEquals(null, cases);
        System.assertEquals(1, cases.size());
        System.assertEquals(3, cases[0].Underlying_Illness_Count__c);
        System.assertEquals('CARDIAC_DISEASE;PREGNANT;OTHER', cases[0].IX_Underlying_Illness_Specify__c);
        System.assertEquals(';;Asthma', cases[0].IX_Underlying_Illness_Specify_Other__c);
        System.assertEquals('Bad ticker!;Twins;Uses inhaler twice daily', cases[0].IX_Underlying_Illness_Description__c);
        System.assertEquals(';22 wks;', cases[0].IX_Pregnancy_Detail__c);
    }

    /**
     * Test with deletion of one of the records
     *
     * @author  Lawrence Coffin <lawrence.coffin@accenture.com>
     * @since   2020-04-27
     */
    private static testMethod void testUnderlyingIllness_Delete()
    {
        List<Underlying_Illness__c> uis = [SELECT Id, Case__c FROM Underlying_Illness__c];
        System.assertNotEquals(null, uis);
        System.assertEquals(3, uis.size());

        //
        // Confirm the record was setup correctly and all the IX_* fields were populated
        //
        List<Case> cases = [SELECT Id,
                                   Underlying_Illness_Count__c,
                                   IX_Underlying_Illness_Specify__c,
                                   IX_Underlying_Illness_Specify_Other__c,
                                   IX_Underlying_Illness_Description__c,
                                   IX_Pregnancy_Detail__c
                            FROM Case
                            WHERE Id = :uis[0].Case__c];
        System.assertNotEquals(null, cases);
        System.assertEquals(1, cases.size());
        System.assertEquals(3, cases[0].Underlying_Illness_Count__c);
        System.assertEquals('CARDIAC_DISEASE;PREGNANT;OTHER', cases[0].IX_Underlying_Illness_Specify__c);
        System.assertEquals(';;Asthma', cases[0].IX_Underlying_Illness_Specify_Other__c);
        System.assertEquals('Bad ticker!;Twins;Daily inhaler', cases[0].IX_Underlying_Illness_Description__c);
        System.assertEquals(';22 wks;', cases[0].IX_Pregnancy_Detail__c);

        //
        // Now, the real test... try deleting one of the Underlying_Illness__c records
        //
        Test.startTest();

        delete uis[1];

        Test.stopTest(); // fire @future methods

        //
        // Confirm the case fields were updated correctly
        //
        cases = [SELECT Id,
                        Underlying_Illness_Count__c,
                        IX_Underlying_Illness_Specify__c,
                        IX_Underlying_Illness_Specify_Other__c,
                        IX_Underlying_Illness_Description__c,
                        IX_Pregnancy_Detail__c
                 FROM Case
                 WHERE Id = :uis[0].Case__c];
        System.assertNotEquals(null, cases);
        System.assertEquals(1, cases.size());
        System.assertEquals(2, cases[0].Underlying_Illness_Count__c);
        System.assertEquals('CARDIAC_DISEASE;OTHER', cases[0].IX_Underlying_Illness_Specify__c);
        System.assertEquals(';Asthma', cases[0].IX_Underlying_Illness_Specify_Other__c);
        System.assertEquals('Bad ticker!;Daily inhaler', cases[0].IX_Underlying_Illness_Description__c);
        System.assertEquals(';', cases[0].IX_Pregnancy_Detail__c);
    }
}