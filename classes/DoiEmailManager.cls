/*
* @purpose: This class is used to send email to the particular target Object Id.
* @author:  Cloud Consulting Group GmbH
* @email:   support@cloudconsulting24.com
*
* @history:
* version                   | author                       | changes
* ====================================================================================
* 1.0 (17-05-2018)          | Cloud Consulting Group GmbH  | initial version
*/
public class DoiEmailManager {
    /**
     * @name : sendEmail
     * @params :  targetObjectId  : This string type varibale holds the record Id to which email will be send.
     * 			  templateId   	  : This string type varibale holds the email template Id.
     * @description : This method send the email to the selected record(targetObjectId).
	 **/
	public static Boolean sendEmail(String targetObjectId, String templateId){
    	Boolean response = false;
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        if(String.isNotBlank(targetObjectId) && String.isNotBlank(templateId)){            
            email.setTargetObjectId(targetObjectId);
            email.setTemplateId(templateId);
            try{
                List<OrgWideEmailAddress> addressIdList= new List<OrgWideEmailAddress>([SELECT Id from OrgWideEmailAddress where Address =:Label.Doi_Sender_Email_Address]);
                if(addressIdList.size() > 0){
                    email.setOrgWideEmailAddressId(addressIdList.get(0).Id);    
                }
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
                response = true;
            }
            catch(Exception e){
                System.debug('Exception Type: '+ e.getTypeName() +', Message: '+ e.getMessage() +', Line Number: '+e.getLineNumber());
            }
        }
        return response;
    }
}