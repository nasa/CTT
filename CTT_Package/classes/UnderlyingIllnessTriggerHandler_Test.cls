/**
 * Underlying_Illness__c Trigger Handler Class
 *
 * @author  Lawrence Coffin <lawrence.coffin@accenture.com>
 * @since   2020-04-27
 */
@IsTest
private class UnderlyingIllnessTriggerHandler_Test {

    /**
     * Test with one Underlying Illness child record
     *
     * @author  Lawrence Coffin <lawrence.coffin@accenture.com>
     * @since   2020-04-27
     */
    private static testMethod void testAddUnderlyingIllness_Single()
    {
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
        Underlying_Illness__c ui = new Underlying_Illness__c();
        ui.Case__c = c.Id;
        ui.Underlying_Illness_Specify__c = 'CARDIAC_DISEASE';
        
        Test.startTest();
        
        insert ui;

        Test.stopTest();

        List<Case> cases = [SELECT Underlying_Illness_Count__c,
                                   IX_Underlying_Illness_Specify__c,
                                   IX_Underlying_Illness_Specify_Other__c,
                                   IX_Underlying_Illness_Description__c,
                                   IX_Pregnancy_Detail__c
                            FROM Case
                            WHERE Id = :c.Id];
        System.assertNotEquals(null, cases);
        System.assertEquals(1, cases.size());
        System.assertEquals(1, cases[0].Underlying_Illness_Count__c);
        System.assertEquals('CARDIAC_DISEASE', cases[0].IX_Underlying_Illness_Specify__c);
        System.assertEquals(null, cases[0].IX_Underlying_Illness_Specify_Other__c);
        System.assertEquals(null, cases[0].IX_Underlying_Illness_Description__c);
        System.assertEquals(null, cases[0].IX_Pregnancy_Detail__c);
    }

    /**
     * Test with two Underlying Illness children records
     *
     * @author  Lawrence Coffin <lawrence.coffin@accenture.com>
     * @since   2020-04-27
     */
    private static testMethod void testAddUnderlyingIllness_Dual()
    {
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

        Underlying_Illness__c ui2 = new Underlying_Illness__c();
        ui2.Case__c = c.Id;
        ui2.Underlying_Illness_Specify__c = 'HYPERTENSION';
        
        Test.startTest();
        
        insert new List<sObject>{ ui1, ui2 };

        Test.stopTest();

        List<Case> cases = [SELECT Underlying_Illness_Count__c,
                                   Underlying_Illness__c,
                                   IX_Underlying_Illness_Specify__c,
                                   IX_Underlying_Illness_Specify_Other__c,
                                   IX_Underlying_Illness_Description__c,
                                   IX_Pregnancy_Detail__c
                            FROM Case
                            WHERE Id = :c.Id];
        System.assertNotEquals(null, cases);
        System.assertEquals(1, cases.size());
        System.assertEquals(2, cases[0].Underlying_Illness_Count__c);
        System.assertEquals('CARDIAC_DISEASE;HYPERTENSION', cases[0].IX_Underlying_Illness_Specify__c);
        System.assertEquals(';', cases[0].IX_Underlying_Illness_Specify_Other__c);
        System.assertEquals(';', cases[0].IX_Underlying_Illness_Description__c);
        System.assertEquals(';', cases[0].IX_Pregnancy_Detail__c);
    }

    /**
     * Test with three Underlying Illness children records
     *
     * @author  Lawrence Coffin <lawrence.coffin@accenture.com>
     * @since   2020-04-27
     */
    private static testMethod void testAddUnderlyingIllness_Triple()
    {
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

        Underlying_Illness__c ui2 = new Underlying_Illness__c();
        ui2.Case__c = c.Id;
        ui2.Underlying_Illness_Specify__c = 'HYPERTENSION';
        
        Underlying_Illness__c ui3 = new Underlying_Illness__c();
        ui3.Case__c = c.Id;
        ui3.Underlying_Illness_Specify__c = 'DIABETES';
        
        Test.startTest();
        
        insert new List<sObject>{ ui1, ui2, ui3 };

        Test.stopTest();

        List<Case> cases = [SELECT Underlying_Illness_Count__c,
                                   IX_Underlying_Illness_Specify__c,
                                   IX_Underlying_Illness_Specify_Other__c,
                                   IX_Underlying_Illness_Description__c,
                                   IX_Pregnancy_Detail__c
                            FROM Case
                            WHERE Id = :c.Id];
        System.assertNotEquals(null, cases);
        System.assertEquals(1, cases.size());
        System.assertEquals(3, cases[0].Underlying_Illness_Count__c);
        System.assertEquals('CARDIAC_DISEASE;HYPERTENSION;DIABETES', cases[0].IX_Underlying_Illness_Specify__c);
        System.assertEquals(';;', cases[0].IX_Underlying_Illness_Specify_Other__c);
        System.assertEquals(';;', cases[0].IX_Underlying_Illness_Description__c);
        System.assertEquals(';;', cases[0].IX_Pregnancy_Detail__c);
    }

    /**
     * Test with three Underlying Illness children records - plus values in all supporting fields (as appropriate)
     *
     * @author  Lawrence Coffin <lawrence.coffin@accenture.com>
     * @since   2020-04-27
     */
    private static testMethod void testAddUnderlyingIllness_TripleFull()
    {
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

        Underlying_Illness__c ui2 = new Underlying_Illness__c();
        ui2.Case__c = c.Id;
        ui2.Underlying_Illness_Specify__c = 'PREGNANT';
        ui2.Underlying_Illness_Description__c = 'Twins';
        ui2.Pregnancy_Detail__c = '22 wks';
        
        Underlying_Illness__c ui3 = new Underlying_Illness__c();
        ui3.Case__c = c.Id;
        ui3.Underlying_Illness_Specify__c = 'OTHER';
        ui3.Underlying_Illness_Specify_Other__c = 'Asthma';
        ui3.Underlying_Illness_Description__c = 'Daily inhaler';
        
        Test.startTest();
        
        insert new List<sObject>{ ui1, ui2, ui3 };

        Test.stopTest();

        List<Case> cases = [SELECT Underlying_Illness_Count__c,
                                   IX_Underlying_Illness_Specify__c,
                                   IX_Underlying_Illness_Specify_Other__c,
                                   IX_Underlying_Illness_Description__c,
                                   IX_Pregnancy_Detail__c
                            FROM Case
                            WHERE Id = :c.Id];
        System.assertNotEquals(null, cases);
        System.assertEquals(1, cases.size());
        System.assertEquals(3, cases[0].Underlying_Illness_Count__c);
        System.assertEquals('CARDIAC_DISEASE;PREGNANT;OTHER', cases[0].IX_Underlying_Illness_Specify__c);
        System.assertEquals(';;Asthma', cases[0].IX_Underlying_Illness_Specify_Other__c);
        System.assertEquals('Bad ticker!;Twins;Daily inhaler', cases[0].IX_Underlying_Illness_Description__c);
        System.assertEquals(';22 wks;', cases[0].IX_Pregnancy_Detail__c);
    }
}