public with sharing class ApprovalProcessHandler {
    @AuraEnabled
    public static void sendApprovalEmail(Id recordId){
        
        
        // Create an approval request for the account
        System.debug(recordId);
        Quote requestedQuote = [SELECT Id, Name, TotalPrice, LineItemCount,DiscountField__C FROM Quote WHERE Id = :recordId];
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setObjectId(requestedQuote.Id);
        req1.setProcessDefinitionNameOrId('Quote_Request_Process');
        req1.setComments('Submitting request for approval.');
                
        
        
        User approver = [Select Id,Email from User where Name like '%Harnivaz%'];
        
        Messaging.SingleEmailMessage approvalEmail = new Messaging.SingleEmailMessage();
        approvalEmail.ToAddresses = new String[]  {approver.Email };
        approvalEmail.setSubject('Approval Request for Quote : '+requestedQuote.Name);
        approvalEmail.setHTMLBody('The details for the Quote :'+requestedQuote.Name+' :<br>  Amount : '+ requestedQuote.TotalPrice+' <br>  Total Discount : '+ requestedQuote.DiscountField__C);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {approvalEmail });
    }
}