/*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* @purpose:		  Test class for the DoiConfirmationCtlr class.
* ─────────────────────────────────────────────────────────────────────────────────────────────────
* @author         (Cloud Consulting Group GmbH)
* @email: 		  support@cloudconsulting24.com
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
@isTest
public class DoiConfirmationCtlrTest {
    
    @testSetup static void setup(){
        List<Lead> leadList= DoiTestDataUtility.createLeads(2);
        List<Contact> contactList = DoiTestDataUtility.createContacts(2);
    }
    
    //This test method is to test the confirmDOI() method. 
    @isTest static void confirmDOITest(){
        //for success condition.
        Lead leadObj = [Select Id, Email_Opt_In__c, Double_Opt_In__c, HasOptedOutOfEmail from Lead LIMIT 1];
        leadObj.Email_Opt_In__c = true;
        leadObj.Double_Opt_In__c = false;
        leadObj.HasOptedOutOfEmail = false;
        update leadObj;
        Integer result = DoiConfirmationCtlr.confirmDOI(leadObj.Id, 'DoiConfirmation', '207.1.0.598');
        System.assertEquals(0, result);
        
        //for Record not found when record Id is not valid.
        Integer result2 = DoiConfirmationCtlr.confirmDOI('0897756', 'DoiConfirmation', '207.1.0.598');
        System.assertEquals(1, result2);
        
        //for Record not found when record Id is blank.
        Integer result5 = DoiConfirmationCtlr.confirmDOI('', 'DoiConfirmation', '207.1.0.598');
        System.assertEquals(1, result5);
                 
        //for already DOI confirmed condition.
        Contact contactObj = [Select Id, Email_Opt_In__c, Double_Opt_In__c, HasOptedOutOfEmail, Email from Contact LIMIT 1];
        contactObj.Email_Opt_In__c = true;
        contactObj.Double_Opt_In__c = true;
        contactObj.HasOptedOutOfEmail = false;
        update contactObj;
        Integer result3 = DoiConfirmationCtlr.confirmDOI(contactObj.Id, 'DoiConfirmation', '207.1.0.598');
        System.assertEquals(4, result3);
        
        //for Unsubscribed condition.
        Contact contactObj1 = [Select Id, Email_Opt_In__c, Double_Opt_In__c, HasOptedOutOfEmail, Email from Contact LIMIT 1];
        contactObj1.Email_Opt_In__c = false;
        contactObj1.Double_Opt_In__c = false;
        contactObj1.HasOptedOutOfEmail = true;
        update contactObj1;
        Integer result4 = DoiConfirmationCtlr.confirmDOI(contactObj1.Id, 'DoiConfirmation', '207.1.0.598');
        System.assertEquals(3, result4);
        
        //for currentPageName is null.
        Contact conObj2 = [Select Id, Email_Opt_In__c, Double_Opt_In__c, HasOptedOutOfEmail, Email from Contact LIMIT 1];
        conObj2.Email_Opt_In__c = true;
        conObj2.Double_Opt_In__c = false;
        conObj2.HasOptedOutOfEmail = false;
        update conObj2;
        Integer result6 = DoiConfirmationCtlr.confirmDOI(conObj2.Id, '', '207.1.0.598');
        System.assertEquals(6, result6);
        
        //success condition for Contact
        Contact conObj3 = [Select Id, Email_Opt_In__c, Double_Opt_In__c, HasOptedOutOfEmail from Contact LIMIT 1];
        conObj3.Email_Opt_In__c = true;
        conObj3.Double_Opt_In__c = false;
        conObj3.HasOptedOutOfEmail = false;
        update conObj3;
        Integer result7 = DoiConfirmationCtlr.confirmDOI(conObj3.Id, 'DoiConfirmation', '207.1.0.598');
        System.assertEquals(0, result7);
    }
    
    //This test method is to test the verifyEmail() method.
    @isTest static void verifyEmailTest(){
        
        //for Success condition.
        Lead leadObj = [Select Id, Email_Opt_In__c, Double_Opt_In__c, HasOptedOutOfEmail, Email from Lead LIMIT 1];
        leadObj.Email_Opt_In__c = true;
        leadObj.Double_Opt_In__c = false;
        leadObj.HasOptedOutOfEmail = false;
        update leadObj;
        Integer result = DoiConfirmationCtlr.verifyEmail(leadObj.Email);
        System.assertEquals(0, result);
        
        //for Record Not Found condition.
        Integer result1 = DoiConfirmationCtlr.verifyEmail('');
        System.assertEquals(6, result1);
        
        //for Email Not found condition.
        Integer result2 = DoiConfirmationCtlr.verifyEmail('abc@gmail.com');
        System.assertEquals(1, result2);
        
        //for Duplicate record found condition.
        Lead leadObj1 = [Select Id, Email_Opt_In__c, Double_Opt_In__c, HasOptedOutOfEmail, Email from Lead where Email!=:leadObj.Email LIMIT 1];
        leadObj1.Email_Opt_In__c = true;
        leadObj1.Double_Opt_In__c = false;
        leadObj1.HasOptedOutOfEmail = false;
        String emailId = leadObj1.Email;
        leadObj1.Email = leadObj.Email;
        update leadObj1;
        Integer result3 = DoiConfirmationCtlr.verifyEmail(leadObj1.Email);
        System.assertEquals(2, result3);
        leadObj1.Email = emailId;
        update leadObj1;
        
        
        //for Unsubscribed condition.
        Contact contactObj = [Select Id, Email_Opt_In__c, Double_Opt_In__c, HasOptedOutOfEmail, Email from Contact LIMIT 1];
        System.debug('BeforecontactObj='+ contactObj);
        contactObj.Email_Opt_In__c = false;
        contactObj.Double_Opt_In__c = false;
        contactObj.HasOptedOutOfEmail = true;
        contactObj.Email = 'asdf@test.com';
        update contactObj;
        System.debug('AftercontactObj='+ contactObj);
        Integer result4 = DoiConfirmationCtlr.verifyEmail(contactObj.Email);
        System.assertEquals(3, result4);  
    }
    
    //This test method is to test the constructor of the DoiConfirmationCtlr(controller of vf page)
    @isTest static void pageTest(){
        Lead leadObj = [Select Id, Email_Opt_In__c, Double_Opt_In__c, HasOptedOutOfEmail, Email from Lead LIMIT 1];
        leadObj.Email_Opt_In__c = true;
        leadObj.Double_Opt_In__c = false;
        leadObj.HasOptedOutOfEmail = false;
        update leadObj;
        PageReference pageRef = Page.DoiConfirmation;
  		pageRef.getParameters().put('id', String.valueOf(leadObj.Id));
  		Test.setCurrentPage(pageRef);
        
        DoiConfirmationCtlr ob = new DoiConfirmationCtlr();
    }
}