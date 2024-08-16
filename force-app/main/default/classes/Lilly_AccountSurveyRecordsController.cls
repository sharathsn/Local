public with sharing class Lilly_AccountSurveyRecordsController {
    @AuraEnabled(cacheable=true)
    public static List<SObject> getRelatedRecords(Id parentId) {
        return [SELECT Id, Name FROM Survey WHERE Name = '2024 Preference Survey' Limit 1];
    }

    @AuraEnabled
    public static void sendEmail(Id recordId, id parentId) {
        Network coomunityId = [SELECT Id FROM Network WHERE Name = 'Surveys' Limit 1];
        Survey surveyRecord = [SELECT Id, Name FROM Survey WHERE id =: recordId Limit 1];
        SurveyInvitation invitation = New SurveyInvitation();
        invitation.CommunityId = coomunityId.id;
        invitation.Name = surveyRecord.name+System.now();
        invitation.OptionsCollectAnonymousResponse = false;
        invitation.OptionsAllowGuestUserResponse = true;
        invitation.OPTIONSALLOWPARTICIPANTACCESSTHEIRRESPONSE = false;
        invitation.OCE__Account__c = parentId;
        invitation.SurveyId = recordId;
        insert invitation;
        // Fetch the record details
        SurveyInvitation record = [SELECT Id, Name, InvitationLink, OCE__Account__r.Name, OCE__Account__r.PersonEmail, OCE__Account__r.OCE__Email__c, OCE__Account__r.IsPersonAccount FROM SurveyInvitation WHERE Id = :invitation.id LIMIT 1];

        // Compose the email body
        /*String emailBody = 'Hello,\n\nHere is the information related to the Survey Invitation:\n' +
            'Survey Name: ' + record.Name + '\n' +
            'Invitation Link: ' + record.InvitationLink + '\n\n' +
            'Thank you.'+ '\n' +'Eli Lilly';*/
        
         String emailBody =  '<html><body>' +
            '<p>Hello '+record.OCE__Account__r.Name+',</p>' +
            '<p>Here is the information related to the Survey Invitation:</p>' +
            '<strong>Survey Name:</strong> ' + surveyRecord.Name +
            '<p><a href="' + record.InvitationLink + '" style="background-color: #0070d2; color: white; padding: 10px 20px; text-align: center; text-decoration: none; display: inline-block; border-radius: 4px;">Open Survey</a></p>' +
            '<p>Thank you.</p>' +
            '</body></html>';

        // Send the email
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] { record.OCE__Account__r.PersonEmail });
        mail.setSubject('Your feedback is important. Help us to improve by taking this survey - ' + surveyRecord.Name);
        mail.setHtmlBody(emailBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}