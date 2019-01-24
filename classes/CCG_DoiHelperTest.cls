/*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* @purpose:		  Test class for the DoiHelper class.
* ─────────────────────────────────────────────────────────────────────────────────────────────────
* @author         (Cloud Consulting Group GmbH)
* @email: 		  support@cloudconsulting24.com
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
@isTest 
public class CCG_DoiHelperTest {
	@testSetup static void setup(){
        List<Lead> leadList = DoiTestDataUtility.createLeads(2);
        List<Contact> contactList = DoiTestDataUtility.createContacts(2);
    }
    
    //Test method for a isConvertedLead method of DoiHelper class.
    @isTest static void isConvertedLeadTest(){
    	//lead is not converted.
    	Lead leadObj = [Select Id, Email from Lead LIMIT 1];
        String result = DoiHelper.isConvertedLead(leadObj.Id);
        System.assertEquals(leadObj.Id, result);
        
        //for a contact record.
    	Contact contactObj = [Select Id, Email from Contact LIMIT 1];
        String result1 = DoiHelper.isConvertedLead(contactObj.Id);
        System.assertEquals(contactObj.Id, result1);
    }
    
    //Test method for a getRecordsBasedOnEmail method of DoiHelper class.
    @isTest static void getRecordsBasedOnEmailTest(){
        //when email Id is blank
        List<SObject> sObjList = DoiHelper.getRecordsBasedOnEmail('');
        System.assertEquals(0, sObjList.size());
        
        //email Id of a Lead
        Lead leadObj = [Select Id, Email from Lead LIMIT 1];
        List<SObject> sObjList1 = DoiHelper.getRecordsBasedOnEmail(leadObj.Email);
        System.assertNotEquals(0, sObjList1.size());
        
        //email Id of a Contact
        Contact contactObj = [Select Id, Email from Contact LIMIT 1];
        List<SObject> sObjList2 = DoiHelper.getRecordsBasedOnEmail(contactObj.Email);
        System.assertNotEquals(0, sObjList2.size());
        
        //invalid email Id
        List<SObject> sObjList3 = DoiHelper.getRecordsBasedOnEmail('qwertyTest@test');
        System.assertEquals(0, sObjList3.size());
    }
    
    //Test method for a getRequiredTemplate method of DoiHelper class.
    @isTest static void getRequiredTemplateTest(){
        //leadObject for Doi confirmation page
        Lead leadObj = [Select Id from Lead LIMIT 1];
        String templateId1 = [Select Id from EmailTemplate where developerName=:Label.Email_Template_For_Doi_Email_Lead Limit 1].Id;
        String result1 = DoiHelper.getRequiredTemplate(leadObj.Id, 'DOI');
        System.assertEquals(templateId1, result1);
        
        //leadObject for UnsubscribeEmail page
        Lead leadObj1 = [Select Id from Lead LIMIT 1];
        String templateId2 = [Select Id from EmailTemplate where developerName=:Label.Email_Template_For_Unsubscribe_Email_Lead Limit 1].Id;
        String result2 = DoiHelper.getRequiredTemplate(leadObj1.Id, 'Unsubscribe');
        System.assertEquals(templateId2, result2);
        
        //leadObject for Resubscribe page
        Lead leadObj2 = [Select Id from Lead LIMIT 1];
        String templateId3 = [Select Id from EmailTemplate where developerName=:Label.Email_Template_For_ReSubscribe_Email_Lead Limit 1].Id;
        String result3 = DoiHelper.getRequiredTemplate(leadObj2.Id, 'ReSubscribe');
        System.assertEquals(templateId3, result3);
        
        //ContactObject for Resubscribe page
        Contact contactObj1 = [Select Id from Contact LIMIT 1];
        String templateId4 = [Select Id from EmailTemplate where developerName=:Label.Email_Template_For_ReSubscribe_Email_Contact Limit 1].Id;
        String result4 = DoiHelper.getRequiredTemplate(contactObj1.Id, 'ReSubscribe');
        System.assertEquals(templateId4, result4);
        
        //ContactObject for UnsubscribeEmail page
        Contact contactObj2 = [Select Id from Contact LIMIT 1];
        String templateId5 = [Select Id from EmailTemplate where developerName=:Label.Email_Template_For_Unsubscribe_Email_Contact Limit 1].Id;
        String result5 = DoiHelper.getRequiredTemplate(contactObj2.Id, 'Unsubscribe');
        System.assertEquals(templateId5, result5);
        
        //ContactObject for Doi confirmation page
        Contact contactObj3 = [Select Id from Contact LIMIT 1];
        String templateId6 = [Select Id from EmailTemplate where developerName=:Label.Email_Template_For_Doi_Email_Contact Limit 1].Id;
        String result6 = DoiHelper.getRequiredTemplate(contactObj3.Id, 'DOI');
        System.assertEquals(templateId6, result6);
        
        //when status is not valid.
        Contact contactObj4 = [Select Id from Contact LIMIT 1];
        String result7 = DoiHelper.getRequiredTemplate(contactObj4.Id, 'anc');
        System.assertEquals('', result7);
    }
}