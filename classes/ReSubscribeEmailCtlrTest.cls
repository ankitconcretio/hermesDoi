/*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* @purpose:		  Test class for the ReSubscribeEmailCtlr class.
* ─────────────────────────────────────────────────────────────────────────────────────────────────
* @author         (Cloud Consulting Group GmbH)
* @email: 		  support@cloudconsulting24.com
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
@isTest
public class ReSubscribeEmailCtlrTest {
    
    @testSetup static void setup(){
      	List<Lead> leadList= DoiTestDataUtility.createLeads(2);
        List<Contact> contactList = DoiTestDataUtility.createContacts(2);
    }
    
    //This test method is to test the resubscribeEmail() method. 
    @isTest static void resubscribeEmailTest(){
        String reSubscribeValues;
        
        //for success condition with Email Opt In.
        Lead leadObj = [Select Id, Email_Opt_In__c, Double_Opt_In__c, HasOptedOutOfEmail, Email from Lead LIMIT 1];
        System.debug('leadObj='+leadObj);
        leadObj.Email_Opt_In__c = false;
        leadObj.Double_Opt_In__c = false;
        leadObj.HasOptedOutOfEmail = true;
        update leadObj;
        reSubscribeValues = '{"emailId":"'+leadObj.Email+'","recordId":"'+leadObj.Id+'","currentPageName":"ResubscribeEmail","ipAddress":"207.8.6.456",'
                							+'"emailOption":true,"telephoneOption":false,"postOption":false,"generalOptOption":false}';
        Integer result = ReSubscribeEmailCtlr.resubscribeEmail(reSubscribeValues);
        System.assertEquals(0, result);
            
        //for success with only Tel opt In.
        Lead leadObj1 = [Select Id, Email_Opt_In__c, Double_Opt_In__c, HasOptedOutOfEmail, Email, Tel_Opt_In__c from Lead where Email!=:leadObj.Email LIMIT 1];
        leadObj1.Email_Opt_In__c = true;
        leadObj1.Double_Opt_In__c = false;
        leadObj1.HasOptedOutOfEmail = false;
        leadObj1.Tel_Opt_In__c = false;
        update leadObj1;
        reSubscribeValues = '{"emailId":"'+leadObj1.Email+'","recordId":"'+leadObj1.Id+'","currentPageName":"ResubscribeEmail","ipAddress":"207.8.6.456",'
                							+'"emailOption":false,"telephoneOption":true,"postOption":false,"generalOptOption":false}';
        Integer result2 = ReSubscribeEmailCtlr.resubscribeEmail(reSubscribeValues);
        System.assertEquals(7, result2);
        
        //for success with only Post opt In..
        Lead leadObj2= [Select Id, Email_Opt_In__c, Double_Opt_In__c, HasOptedOutOfEmail, Email, Postal_Opt_In__c from Lead where Email!=:leadObj.Email LIMIT 1];
        leadObj2.Email_Opt_In__c = true;
        leadObj2.Double_Opt_In__c = false;
        leadObj2.HasOptedOutOfEmail = false;
        leadObj2.Postal_Opt_In__c = false;
        update leadObj2;
        reSubscribeValues = '{"emailId":"'+leadObj2.Email+'","recordId":"'+leadObj2.Id+'","currentPageName":"ResubscribeEmail","ipAddress":"207.8.6.456",'
                							+'"emailOption":false,"telephoneOption":false,"postOption":true,"generalOptOption":false}';
        Integer result3 = ReSubscribeEmailCtlr.resubscribeEmail(reSubscribeValues);
        System.assertEquals(8, result3);
        
        //for success with only Post & tel opt In..
        Lead leadObj4= [Select Id, Email_Opt_In__c, Tel_Opt_In__c, HasOptedOutOfEmail, Email, Postal_Opt_In__c from Lead where Email!=:leadObj.Email LIMIT 1];
        leadObj4.Email_Opt_In__c = true;
        leadObj4.HasOptedOutOfEmail = false;
		leadObj4.Postal_Opt_In__c = false;
        leadObj4.Tel_Opt_In__c = false;
        update leadObj4;
        reSubscribeValues = '{"emailId":"'+leadObj2.Email+'","recordId":"'+leadObj2.Id+'","currentPageName":"ResubscribeEmail","ipAddress":"207.8.6.456",'
                							+'"emailOption":false,"telephoneOption":true,"postOption":true,"generalOptOption":false}';
        Integer result10 = ReSubscribeEmailCtlr.resubscribeEmail(reSubscribeValues);
        System.assertEquals(6, result10);
        
        //for Record not found when record Id is not valid.
        reSubscribeValues = '{"emailId":"'+leadObj4.Email+'","recordId":"","currentPageName":"ResubscribeEmail","ipAddress":"207.8.6.456",'
                							+'"emailOption":false,"telephoneOption":false,"postOption":false,"generalOptOption":false}';
        Integer result5 = ReSubscribeEmailCtlr.resubscribeEmail(reSubscribeValues);
        System.assertEquals(4, result5);

        //for Record not found when record Id & email Id is null.
        reSubscribeValues = '{"emailId":"","recordId":"","currentPageName":"ResubscribeEmail","ipAddress":"207.8.6.456",'
                							+'"emailOption":false,"telephoneOption":false,"postOption":false,"generalOptOption":false}';
        Integer result4 = ReSubscribeEmailCtlr.resubscribeEmail(reSubscribeValues);
        System.assertEquals(2, result4);
        
        //user verified using emailId and update the record successfully.
        Lead leadObj5= [Select Id, Email_Opt_In__c, Tel_Opt_In__c, HasOptedOutOfEmail, Email, Postal_Opt_In__c from Lead where Email!=:leadObj.Email LIMIT 1];
        leadObj5.Email_Opt_In__c = false;
        leadObj5.HasOptedOutOfEmail = false;
		leadObj5.Postal_Opt_In__c = false;
        leadObj5.Tel_Opt_In__c = false;
        update leadObj5;
        reSubscribeValues = '{"emailId":"'+leadObj5.Email+'","recordId":"'+leadObj5.Id+'","currentPageName":"ResubscribeEmail","ipAddress":"207.8.6.456",'
                							+'"emailOption":false,"telephoneOption":false,"postOption":false,"generalOptOption":true}';
        Integer result8 = ReSubscribeEmailCtlr.resubscribeEmail(reSubscribeValues);
        System.assertEquals(5, result8);
        
        //for email not found & also no record Id is there.
        Lead leadObj6= [Select Id, Email_Opt_In__c, Tel_Opt_In__c, HasOptedOutOfEmail, Email, Postal_Opt_In__c from Lead where Email!=:leadObj.Email LIMIT 1];
        leadObj6.Email_Opt_In__c = false;
        update leadObj6;
        reSubscribeValues = '{"emailId":"abcTes@hotmail.com","recordId":"'+leadObj6.Id+'","currentPageName":"ResubscribeEmail","ipAddress":"207.8.6.456",'
                							+'"emailOption":false,"telephoneOption":false,"postOption":false,"generalOptOption":true}';
        Integer result6 = ReSubscribeEmailCtlr.resubscribeEmail(reSubscribeValues);
        System.assertEquals(1, result6);
        
        //ip address & current page name blank.
        Lead leadObj7 = [Select Id, Email_Opt_In__c, Tel_Opt_In__c, HasOptedOutOfEmail, Email, Postal_Opt_In__c from Lead where Email!=:leadObj.Email LIMIT 1];
        leadObj7.Email_Opt_In__c = false;
        update leadObj7;
        reSubscribeValues = '{"emailId":"'+leadObj7.Email+'","recordId":"'+leadObj7.Id+'","currentPageName":"","ipAddress":"",'
                							+'"emailOption":false,"telephoneOption":false,"postOption":false,"generalOptOption":true}';
        Integer result7 = ReSubscribeEmailCtlr.resubscribeEmail(reSubscribeValues);
        System.assertEquals(3, result7);
    }
    
    //This test method is to test the constructor of the ReSubscribeEmailCtlr(controller of vf page)
    @isTest static void pageTest(){
        Lead leadObj = [Select Id, Email_Opt_In__c, Double_Opt_In__c, HasOptedOutOfEmail, Email from Lead LIMIT 1];
        leadObj.Email_Opt_In__c = false;
        leadObj.Double_Opt_In__c = false;
        leadObj.HasOptedOutOfEmail = true;
        update leadObj;
        PageReference pageRef = Page.ReSubscribeEmail;
  		pageRef.getParameters().put('id', String.valueOf(leadObj.Id));
  		Test.setCurrentPage(pageRef);
        
        ReSubscribeEmailCtlr ob = new ReSubscribeEmailCtlr();
    }
}