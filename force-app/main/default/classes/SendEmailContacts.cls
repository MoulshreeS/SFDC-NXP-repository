public class SendEmailContacts {
    
    public static void sendemail(List<Lead> leads){
        
              
        list<Lead>  leadwithdifferentfeedbackemail = new List<Lead>();
        string loggedInUser;
        set<string> emailSet=new set<string>();
               
        for(lead l : leads){
            
            if(l.Disti_Feedback_Email_Address__c != l.Distributor_Contact__r.email){
                 leadwithdifferentfeedbackemail.add(l);
                emailSet.add(l.Disti_Feedback_Email_Address__c);
            }
        }
       
        List<Contact> con = [select id,email,Name,Firstname,Lastname,Community_web_country__c,User_Region__c,Account.Name from contact where email in : emailset];
        Map<String,List<contact>> mapcon = new Map<String,List<contact>>();
        for(contact c : con){
            if(!mapcon.containsKey(c.Email)){
                mapcon.put(c.Email,new list<contact>{c});
            }
          
        }
 
       
        
       
         String Htmlbody = '<table border="1" width="50%" empty-cells: hide; style ="border-collapse: collapse";><tr><th>Lead ID</th><th>Lead Region</th><th>Lead Status</th><th>Distributor Tracking Number</th><th>Distributor Contact</th><th>Distributor Contact Email Address</th><th>Distributor Contact Account</th><th>Distributor Contact Region</th><th>Disti Feedback Email Address</th><th>Disti Feedback Account</th><th>Disti Feedback Region</th><th>Disti Feedback Name</th><th>Disti Feedback Contact ID</th></tr>';
         //  String Htmlbody = '<table border="1" width="50%" empty-cells: hide; style ="border-collapse: collapse";><tr><th>Lead ID</th><th>Lead Region</th><th>Distributor Contact</th><th>Distributor Contact Email Address</th><th>Distributor Contact Account</th><th>Distributor Contact Region</th><th>Distributor Contact Country</th><th>Disti Feedback Email Address</th><th>Disti Feedback Account</th><th>Disti Feedback Region</th><th>Disti Feedback Country</th><th>Disti Feedback Name</th><th>Disti Feedback Contact ID</th></tr>';
      
                for (Lead l : leadwithdifferentfeedbackemail){
                    Id conid;
       				String conName;
                   	String confirstname;
                    String conlastname;
                    String conemail;
                    String conuserregion;
                    String concountry;
                    String blnk = ' ';
                    Id leadid = l.id;
                    String leadregion = l.Region__c;
                    String ownerName = l.owner.Name;
                    String Leadname = l.Name;
                    String Leadstatus = l.Status;
                    String TrackingNumber = l.Distributor_Tracking_Number__c;
                    String Distiname = l.Distributor_contact__r.name;
                    String Distifirstname = l.Distributor_contact__r.firstname;
                    String Distilastname = l.Distributor_contact__r.lastname;
                    String Distiemail = l.Distributor_contact__r.email;
                    String Disticountry = l.Distributor_contact__r.Community_web_country__c;
                 	Id DistiContact = l.Distributor_Contact__c;
                    String conaccname;
                    String Distiaccname = l.Distributor_Contact__r.Account.Name;
                    String Distiregion = l.Distributor_contact__r.User_Region__c;
                    String Distifeedbackemail = l.Disti_Feedback_Email_Address__c;
                    
            if(mapcon.containskey(l.Disti_Feedback_Email_Address__c.toLowerCase())){
                for(contact c : mapcon.get(l.Disti_Feedback_Email_Address__c.toLowerCase())){
                  conid = c.id;
                  conName = c.Name;
                  confirstname = c.FirstName;
                  conlastname = c.LastName; 
                  conemail = c.email;
                  conuserregion = c.User_Region__c;
                  conaccname = c.Account.Name; 
                  concountry = c.Community_web_country__c;
  
                }
             
             
            Htmlbody += '<tr><td>' + leadid + '</td><td>' + leadregion + '</td><td>' +  Leadstatus + '</td><td>' +  TrackingNumber +  '</td><td><a href="https://nxp.my.salesforce.com/' + DistiContact + '">' + Distilastname + ',' + Distifirstname + '</a></td><td>' + Distiemail +  '</td><td>' + Distiaccname +  '</td><td>' + Distiregion +  '</td><td>' + Distifeedbackemail + '</td><td>' + conaccname + '</td><td>' + conuserregion + '</td><td><a href="https://nxp.my.salesforce.com/' + conid + '">' +  confirstname + ',' + conlastname + '</a></td><td>' + conid +  '</td></tr></br>'; 
                // Htmlbody += '<tr><td>' + leadid + '</td><td>' + leadregion +  '</td><td><a href="https://nxp--full.my.salesforce.com/' + DistiContact + '">' + 
  //Distilastname + ',' + Distifirstname + '</a></td><td>' + Distiemail +  '</td><td>' + Distiaccname +  '</td><td>' + Distiregion +  '</td><td>' + Disticountry +  '</td><td>' + 
  //Distifeedbackemail + '</td><td>' + conaccname + '</td><td>' + conuserregion +  '</td><td>' + concountry +  '</td><td><a href="https://nxp--disti2.my.salesforce.com/' + conid + '">' +  
  //confirstname + ',' + conlastname + '</a></td><td>' + conid +  '</td></tr></br>'; 
            }
                    else {
                        
    		
             
             
              Htmlbody += '<tr><td>' + leadid + '</td><td>' + leadregion + '</td><td>' + Leadstatus + '</td><td>' +  TrackingNumber +  '</td><td><a href="https://nxp.my.salesforce.com/' + DistiContact + '">' + Distilastname + ',' + Distifirstname + '</a></td><td>' + Distiemail +  '</td><td>' + Distiaccname +  '</td><td>' + Distiregion +  '</td><td>' + Distifeedbackemail + '</td><td>' + 'null' +  '</td><td>' + 'null' + '</td><td>' + 'null' + '</td><td>' + 'null' +  '</td></tr></br>';
               //Htmlbody += '<tr><td>' + leadid + '</td><td>' + leadregion +  '</td><td><a href="https://nxp--full.my.salesforce.com/' + DistiContact + '">' + Distilastname + ',' + Distifirstname + '</a></td><td>' + Distiemail +  '</td><td>' + Distiaccname +  '</td><td>' + Distiregion +  '</td><td>' + Disticountry + '</td><td>' + Distifeedbackemail + '</td><td>' + blnk +  '</td><td>' + blnk + '</td><td>' + blnk + '</td><td>' + blnk + '</td><td>' + blnk +  '</td></tr></br>';
                    }
        }
        
       Htmlbody += '</table></br>' ; 
   
        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        blob csvBlob = Blob.valueOf(Htmlbody);
        string csvname= 'Contact.xls';
        csvAttc.setFileName(csvname);
        csvAttc.setBody(csvBlob);
        
                User u = [select Id,Name, username from User where Id = :UserInfo.getUserId()];
                                     if(u !=null){
                                         loggedInUser=u.Name;
                                     }
        
        

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage sendEmail = new Messaging.SingleEmailMessage();

		String mailbody = 'Hello Melissa/kevin'+ ',' + '</br></br>' + 'Please find the attached list of contacts.</br>' + '</br> Regards, </br>' + loggedInUser;
        sendEmail.setToAddresses(new String[]{'melissa.arosemena@nxp.com','k.hughes@nxp.com'});
		sendEmail.setSubject('Contact Details');
        sendEmail.setHtmlBody(mailbody);
        sendEmail.setSaveAsActivity(false);
		sendEmail.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
        emails.add(sendEmail);
        
           if (emails != NULL && emails.size() > 0)
        {
            try{
        
        Messaging.sendEmail(emails);
            }
            catch(exception e){
                                
            }   
        
    }
        
    }

}