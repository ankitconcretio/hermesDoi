/*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* @purpose:		  Test class for the UnsubscribeEmailCtlr class.
* ─────────────────────────────────────────────────────────────────────────────────────────────────
* @author         (Cloud Consulting Group GmbH)
* @email: 		  support@cloudconsulting24.com
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
@isTest
public class UnsubscribeEmailCtlrTest {
    
    @testSetup static void setup(){
        List<Lead> leadList= DoiTestDataUtility.createLeads(2);
        List<Contact> contactList = DoiTestDataUtility.createContacts(2);
    }
    
    //This test method is to test the unsubscribeEmail() method. 
    @isTest static void unsubscribeEmailTest(){
        String unsubscribeValues;
        //for success condition.
        Lead leadObj = [Select Id, Email_Opt_In__c, Double_Opt_In__c, HasOptedOutOfEmail, Email from Lead LIMIT 1];
        System.debug('leadObj='+leadObj);
        leadObj.Email_Opt_In__c = true;
        leadObj.Double_Opt_In__c = false;
        leadObj.HasOptedOutOfEmail = false;
        update leadObj;
        unsubscribeValues = '{"recordId":"'+leadObj.Id+'","currentPageName":"UnsubscribeEmail","ipAddress":"207.8.6.456",'
                							+'"emailOption":false,"telephoneOption":false,"postOption":false}';
        Integer result = UnsubscribeEmailCtlr.unsubscribeEmail(unsubscribeValues);
        System.assertEquals(0, result);

        //for Record not found when record Id is blank.
        unsubscribeValues = '{"recordId":"","currentPageName":"UnsubscribeEmail","ipAddress":"207.8.6.456",'
                			+'"emailOption":false,"telephoneOption":false,"postOption":false}';
        Integer result2 = UnsubscribeEmailCtlr.unsubscribeEmail(unsubscribeValues);
        System.assertEquals(1, result2);
        
        //for Record not found when record Id is not valid.
        unsubscribeValues = '{"recordId":"0897756","currentPageName":"UnsubscribeEmail","ipAddress":"207.8.6.456",'
                			+'"emailOption":false,"telephoneOption":false,"postOption":false}';
        Integer result4 = UnsubscribeEmailCtlr.unsubscribeEmail(unsubscribeValues);
        System.assertEquals(1, result4);
        
        //for already unsubscribed condition.
        Contact contactObj = [Select Id, Email_Opt_In__c, Double_Opt_In__c, HasOptedOutOfEmail, Email, Opt_Out__c from Contact LIMIT 1];
        contactObj.Email_Opt_In__c = false;
        contactObj.Double_Opt_In__c = false;
        contactObj.HasOptedOutOfEmail = true;
        contactObj.Opt_Out__c = true;
        update contactObj;
        unsubscribeValues = '{"recordId":"'+contactObj.Id+'","currentPageName":"UnsubscribeEmail","ipAddress":"207.8.6.456",'
                							+'"emailOption":false,"telephoneOption":false,"postOption":false}';
        Integer result3 = UnsubscribeEmailCtlr.unsubscribeEmail(unsubscribeValues);
        System.assertEquals(3, result3);
        
        //for ip address is null.
        Lead leadObj2 = [Select Id, Email_Opt_In__c, Double_Opt_In__c, HasOptedOutOfEmail, Opt_Out__c, Email from Lead LIMIT 1];
        leadObj2.Email_Opt_In__c = true;
        leadObj2.Double_Opt_In__c = false;
        leadObj2.HasOptedOutOfEmail = false;
        leadObj2.Opt_Out__c = false;
        update leadObj2;
        unsubscribeValues = '{"recordId":"'+leadObj2.Id+'","currentPageName":"UnsubscribeEmail","ipAddress":"",'
                							+'"emailOption":false,"telephoneOption":false,"postOption":false}';
        Integer result5 = UnsubscribeEmailCtlr.unsubscribeEmail(unsubscribeValues);
        System.assertEquals(5, result5);
        
        //for tele opt out & postal opt out & email opt out
        Lead leadObj3 = [Select Id,Email_Opt_In__c,Double_Opt_In__c,HasOptedOutOfEmail,Postal_Opt_In__c,Tel_Opt_In__c,Email from Lead LIMIT 1];
        leadObj3.Email_Opt_In__c = true;
        leadObj3.Double_Opt_In__c = false;
        leadObj3.HasOptedOutOfEmail = false;
        leadObj3.Postal_Opt_In__c = true;
        leadObj3.Tel_Opt_In__c = true;
        update leadObj3;
        unsubscribeValues = '{"recordId":"'+leadObj3.Id+'","currentPageName":"UnsubscribeEmail","ipAddress":"207.8.6.456",'
                							+'"emailOption":true,"telephoneOption":true,"postOption":true}';
        Integer result6 = UnsubscribeEmailCtlr.unsubscribeEmail(unsubscribeValues);
        System.assertEquals(0, result6);
        
        //for tele opt out & postal opt out
        Lead leadObj4 = [Select Id,Email_Opt_In__c,Double_Opt_In__c,HasOptedOutOfEmail,Postal_Opt_In__c,Tel_Opt_In__c,Email,Opt_Out__c from Lead LIMIT 1];
        leadObj4.Postal_Opt_In__c = true;
        leadObj4.Email_Opt_In__c = true;
        leadObj4.Tel_Opt_In__c = true;
        leadObj4.Opt_Out__c = false;
        update leadObj4;
        unsubscribeValues = '{"recordId":"'+leadObj4.Id+'","currentPageName":"UnsubscribeEmail","ipAddress":"207.8.6.456",'
                							+'"emailOption":false,"telephoneOption":true,"postOption":true}';
        Integer result7 = UnsubscribeEmailCtlr.unsubscribeEmail(unsubscribeValues);
        System.assertEquals(6, result7);
        
        //for tele opt out
        Lead leadObj5 = [Select Id,Email_Opt_In__c,Double_Opt_In__c,HasOptedOutOfEmail,Postal_Opt_In__c,Tel_Opt_In__c,Email,Opt_Out__c from Lead LIMIT 1];
        leadObj5.Tel_Opt_In__c = true;
        leadObj5.Opt_Out__c = false;
        update leadObj5;
        unsubscribeValues = '{"recordId":"'+leadObj5.Id+'","currentPageName":"UnsubscribeEmail","ipAddress":"207.8.6.456",'
                							+'"emailOption":false,"telephoneOption":true,"postOption":false}';
        Integer result8 = UnsubscribeEmailCtlr.unsubscribeEmail(unsubscribeValues);
        System.assertEquals(7, result8);
        
        //for postal opt out
        Lead leadObj6 = [Select Id,Email_Opt_In__c,Double_Opt_In__c,HasOptedOutOfEmail,Postal_Opt_In__c,Tel_Opt_In__c,Email,Opt_Out__c from Lead LIMIT 1];
        leadObj6.Postal_Opt_In__c = true;
        leadObj6.Opt_Out__c = false;
        update leadObj6;
        unsubscribeValues = '{"recordId":"'+leadObj6.Id+'","currentPageName":"UnsubscribeEmail","ipAddress":"207.8.6.456",'
                							+'"emailOption":false,"telephoneOption":false,"postOption":true}';
        Integer result9 = UnsubscribeEmailCtlr.unsubscribeEmail(unsubscribeValues);
        System.assertEquals(8, result9);
        
        //for email & postal opt out
        Lead leadObj7 = [Select Id,Email_Opt_In__c,Double_Opt_In__c,HasOptedOutOfEmail,Postal_Opt_In__c,Tel_Opt_In__c,Email,Opt_Out__c from Lead LIMIT 1];
        leadObj7.Postal_Opt_In__c = true;
        leadObj7.Email_Opt_In__c = true;
        leadObj7.Tel_Opt_In__c = true;
        leadObj7.Opt_Out__c = false;
        update leadObj7;
        unsubscribeValues = '{"recordId":"'+leadObj7.Id+'","currentPageName":"UnsubscribeEmail","ipAddress":"207.8.6.456",'
                							+'"emailOption":true,"telephoneOption":false,"postOption":true}';
        Integer result10 = UnsubscribeEmailCtlr.unsubscribeEmail(unsubscribeValues);
        System.assertEquals(10, result10);
        
        //for email & tel opt out
        Lead leadObj8 = [Select Id,Email_Opt_In__c,Double_Opt_In__c,HasOptedOutOfEmail,Postal_Opt_In__c,Tel_Opt_In__c,Email,Opt_Out__c from Lead LIMIT 1];
        leadObj8.Tel_Opt_In__c = true;
        leadObj8.Email_Opt_In__c = true;
        leadObj8.Opt_Out__c = false;
        leadObj8.Postal_Opt_In__c = true;
        update leadObj8;
        unsubscribeValues = '{"recordId":"'+leadObj8.Id+'","currentPageName":"UnsubscribeEmail","ipAddress":"207.8.6.456",'
                							+'"emailOption":true,"telephoneOption":true,"postOption":false}';
        Integer result11 = UnsubscribeEmailCtlr.unsubscribeEmail(unsubscribeValues);
        System.assertEquals(9, result11);
        
        //for email opt out
        Lead leadObj9 = [Select Id,Email_Opt_In__c,Double_Opt_In__c,HasOptedOutOfEmail,Postal_Opt_In__c,Tel_Opt_In__c,Email,Opt_Out__c from Lead LIMIT 1];
        leadObj9.Email_Opt_In__c = true;
        leadObj9.Opt_Out__c = false;
        update leadObj9;
        unsubscribeValues = '{"recordId":"'+leadObj9.Id+'","currentPageName":"UnsubscribeEmail","ipAddress":"207.8.6.456",'
                							+'"emailOption":true,"telephoneOption":false,"postOption":false}';
        Integer result12 = UnsubscribeEmailCtlr.unsubscribeEmail(unsubscribeValues);
        System.assertEquals(11, result12);
    }
    
    //This test method is to test the verifyEmailForUnsubscribe() method.
    @isTest static void verifyEmailForUnsubscribeTest(){
        //for Success condition.
        Lead leadObj = [Select Id, Email_Opt_In__c, Double_Opt_In__c, HasOptedOutOfEmail, Email from Lead LIMIT 1];
        System.debug('leadObj='+leadObj);
        leadObj.Email_Opt_In__c = true;
        leadObj.Double_Opt_In__c = true;
        leadObj.HasOptedOutOfEmail = false;
        update leadObj;
        Integer result = UnsubscribeEmailCtlr.verifyEmailForUnsubscribe(leadObj.Email);
        System.assertEquals(0, result);
        
        //for Record Not Found condition.
        Integer result1 = UnsubscribeEmailCtlr.verifyEmailForUnsubscribe('');
        System.assertEquals(5, result1);
        
        //for Email Not found condition.
        Integer result2 = UnsubscribeEmailCtlr.verifyEmailForUnsubscribe('abc@gmail.com');
        System.assertEquals(1, result2);
        
        //for Duplicate record found condition.
        Lead leadObj1 = [Select Id, Email_Opt_In__c, Double_Opt_In__c, HasOptedOutOfEmail, Email from Lead where Email!=:leadObj.Email LIMIT 1];
        leadObj1.Email_Opt_In__c = true;
        leadObj1.Double_Opt_In__c = false;
        leadObj1.HasOptedOutOfEmail = false;
        String emailId = leadObj1.Email;
        leadObj1.Email = leadObj.Email;
        update leadObj1;
        Integer result3 = UnsubscribeEmailCtlr.verifyEmailForUnsubscribe(leadObj1.Email);
        System.assertEquals(2, result3);
        leadObj1.Email = emailId;
        update leadObj1;
        
        //for Unsubscribed condition.
        Contact contactObj = [Select Id, Email_Opt_In__c, Double_Opt_In__c, HasOptedOutOfEmail, Email, Opt_Out__c from Contact LIMIT 1];
        System.debug('BeforecontactObj='+ contactObj);
        contactObj.Email_Opt_In__c = false;
        contactObj.Double_Opt_In__c = false;
        contactObj.HasOptedOutOfEmail = true;
        contactObj.Opt_Out__c = true;
        update contactObj;
        Integer result4 = UnsubscribeEmailCtlr.verifyEmailForUnsubscribe(contactObj.Email);
        System.assertEquals(3, result4);
    }
    
    //This test method is to test the constructor of the UnsubscribeEmailCtlr(controller of vf page)
    @isTest static void pageTest(){
        Lead leadObj = [Select Id, Email_Opt_In__c, Double_Opt_In__c, HasOptedOutOfEmail, Email from Lead LIMIT 1];
        leadObj.Email_Opt_In__c = true;
        leadObj.Double_Opt_In__c = false;
        leadObj.HasOptedOutOfEmail = false;
        update leadObj;
        PageReference pageRef = Page.UnsubscribeEmail;
  		pageRef.getParameters().put('id', String.valueOf(leadObj.Id));
  		Test.setCurrentPage(pageRef);
        
        UnsubscribeEmailCtlr ob = new UnsubscribeEmailCtlr();
    }
}