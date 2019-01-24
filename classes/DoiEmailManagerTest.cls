/*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* @purpose:		  Test class for the DoiEmailManager class.
* ─────────────────────────────────────────────────────────────────────────────────────────────────
* @author         (Cloud Consulting Group GmbH)
* @email: 		  support@cloudconsulting24.com
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
@isTest
public class DoiEmailManagerTest {
	@testSetup static void setup(){
        List<Lead> leadList = DoiTestDataUtility.createLeads(2);
        List<Contact> contactList = DoiTestDataUtility.createContacts(2);
    }
    
    //Test method for a sendEmail method of DoiHelper class.
    @isTest static void sendEmailTest(){
        //on lead object with valid template of Lead Object.
    	Lead leadObj = [Select Id, Email from Lead LIMIT 1];
        String templateId1 = [Select Id from EmailTemplate where developerName=:Label.Email_Template_For_Doi_Email_Lead Limit 1].Id;
        Boolean result1 = DoiEmailManager.sendEmail(leadObj.Id, templateId1);
        System.assertEquals(true, result1);
        
        //on Contact object with valid template of Contact Object.
    	Contact contactObj1 = [Select Id from Contact LIMIT 1];
        String templateId2 = [Select Id from EmailTemplate where developerName=:Label.Email_Template_For_ReSubscribe_Email_Contact Limit 1].Id;
        Boolean result2 = DoiEmailManager.sendEmail(contactObj1.Id, templateId2);
        System.assertEquals(true, result2);
        
        //on Contact object with blank template Id.
    	Contact contactObj2 = [Select Id from Contact LIMIT 1];
        Boolean result3 = DoiEmailManager.sendEmail(contactObj2.Id, '');
        System.assertEquals(false, result3);
    }
}