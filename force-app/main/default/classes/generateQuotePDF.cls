Public class generateQuotePDF{
    
    @InvocableMethod(Label='QuoteGenerationPDF')
    public static void CreateQuote(List<Id> quoteIds)  
    { 
        System.debug(quoteIds);
        createQuoteFutureMethod(quoteIds);
    }
    
    @future(callout=true)
    public static void createQuoteFutureMethod (List<Id> quoteIds) {
        
        //Get the Quote Template Id from Custom Settings
        String quoteTemplateId = Label.QuoteTemplateId;
        
        //List variable to get all the Quote Documents
        List<QuoteDocument> lstQuoteDoc = new List<QuoteDocument>();
        
        if(!quoteIds.isEmpty() && quoteIds.size() > 0) {
            
            for(Id quoteId :quoteIds) {
                String baseUrl = System.Url.getOrgDomainUrl().toExternalForm();
                String quoteUrl = baseUrl + '/quote/quoteTemplateDataViewer.apexp?id=' + quoteId + '&summlid=' + quoteTemplateId;
                //call the quote url
                PageReference pageRef = new PageReference(quoteUrl);
                System.debug(pageRef);
                //get the quotePdf
                Blob quoteBlob;
                quoteBlob = pageRef.getContentAsPDF();
                System.debug(quoteBlob);
                
                //initialze the QuoteDocument to hold the quote pdf for insertion
                QuoteDocument quoteDoc = new QuoteDocument();
                quoteDoc.Document = quoteBlob;
                quoteDoc.QuoteId = quoteId;
                lstQuoteDoc.add(quoteDoc);
            }
        }
        
        if(!lstQuoteDoc.isEmpty() && lstQuoteDoc.size() > 0) {
            insert lstQuoteDoc;
        }
    }
}
//This is test commit to check versioning