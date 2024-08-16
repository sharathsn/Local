public class lwcCSVUploaderController {

    // Lilly_Scientific_Congress__cAccountOCE__Address__cOCE__Affiliation__cLilly_Payment__cOCE__Publication__cLilly_Claim__cOCE__ClinicalTrial__cLilly_Referrals_Received__cLilly_ReferralsSent__cLilly_Custom_Attribute__cLilly_Tag__cLilly_Tag_Assignment__cLilly_User_Tag_Access__c
    @AuraEnabled  
    public static String saveFile(String base64Data)      
    {    
        String data    = JSON.deserializeUntyped(base64Data).toString();        
        list<Lilly_Non_Contract_Engagement__c> listMeetingRequest = new list<Lilly_Non_Contract_Engagement__c>();
        list<String> lstCSVLines = data.split('\n');      
        for(Integer i = 1; i < lstCSVLines.size(); i++)            
        {            
            Lilly_Non_Contract_Engagement__c meetingRequest = new Lilly_Non_Contract_Engagement__c();            
            String csvLine = lstCSVLines[i];            
            String prevLine = csvLine;            
            Integer startIndex;            
            Integer endIndex;            
            List<String> csvRowData = new List<String>();            
            for(String column : csvLine.split(','))                
            {                
                column = column.replaceAll(':quotes:', '').replaceAll(':comma:', ',');                
                csvRowData.add(column);                
            }            
            meetingRequest.Lilly_External_ID__c = csvRowData[0];     
            //meetingRequest.LillyCongress_or_Meeting__c = csvRowData[2]; 
            meetingRequest.LilIy_Functional_Owner__c = csvRowData[3];            
            meetingRequest.LilIy_Meeting_Room_Name__c = csvRowData[4];   
            meetingRequest.LilIy_Discussion_Type_or_Topic__c = csvRowData[5];   
            if(!String.isBlank(csvRowData[6]))
            meetingRequest.LilIy_Thought_Leader__c  = Id.valueOf(csvRowData[6].trim());// '001DH0000115DX9YAM';           //Id.valueOf(csvRowData[6]);   
            listMeetingRequest.add(meetingRequest);            
        }     
        if (listMeetingRequest != null)           
        {            
            //insert listMeetingRequest;            
        }        
        // Insert accounts and capture results
        Database.SaveResult[] saveResults = Database.insert(listMeetingRequest, false);
        
        // Prepare the results content
        String fileContent = 'Status,Id,TL ID,Meeting,Functional Owner,Meeting Room,Discussion Type,Thought Leader, Errors\n';
        for (Integer i = 0; i < saveResults.size(); i++) {
            Database.SaveResult saveResult = saveResults[i];
            Lilly_Non_Contract_Engagement__c meetingRequest = listMeetingRequest[i];
            
            if (saveResult.isSuccess()) {
                fileContent += 'Success,' + saveResult.getId() + ',' + meetingRequest.Lilly_External_ID__c + ',' + meetingRequest.LillyCongress_or_Meeting__c + ',' + meetingRequest.LilIy_Functional_Owner__c + ',' + meetingRequest.LilIy_Meeting_Room_Name__c + ',' + meetingRequest.LilIy_Discussion_Type_or_Topic__c + ',' + meetingRequest.LilIy_Thought_Leader__c + ',\n';
            } else {
                fileContent += 'Failure,,' + meetingRequest.Lilly_External_ID__c + ',' + meetingRequest.LillyCongress_or_Meeting__c + ',' + meetingRequest.LilIy_Functional_Owner__c + ',' + meetingRequest.LilIy_Meeting_Room_Name__c + ',' + meetingRequest.LilIy_Discussion_Type_or_Topic__c + ',' + meetingRequest.LilIy_Thought_Leader__c + ',';
                for (Database.Error error : saveResult.getErrors()) {
                    fileContent += error.getMessage() + ' ';
                }
                fileContent += '\n';
            }
        }
        
        // Create a file
        Blob fileBody = Blob.valueOf(fileContent);
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.VersionData = fileBody;
        contentVersion.Title = 'MeetingRequestImportResults'+System.now()+'.csv';
        contentVersion.PathOnClient = 'MeetingRequestImportResults'+System.now()+'.csv';
        insert contentVersion;

        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:contentVersion.Id].ContentDocumentId;
        return conDocId;
    }            
}