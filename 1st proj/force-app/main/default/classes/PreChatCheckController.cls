global class PreChatCheckController {
	@RemoteAction
    global static String findOrCreateContactForLoggedInUser(String emailId,String fName,String lName,String country,String company){
        String contactId='';
        if(emailId!=null && emailId.trim().length()>0){
        	List<Contact> c = [SELECT Id from Contact where Email = :emailId]; 
            if(c!=null && (!c.isEmpty())){
            	return c[0].id;    
            }else{
               	List<Account> acc = [SELECT  Id from Account where Name='NXP Community'];
                if(acc!=null &&(!acc.isEmpty())){
                    if(country==null || country.trim().length()==0)
                        country='Unknown';
                	Contact con = new Contact(FirstName=fname,LastName=lname,Email=emailId,AccountId=acc[0].id,Community_web_country__c=country,is_Active_Community_User__c=true);    
                    Database.SaveResult sr= Database.insert(con);
                    if(sr.isSuccess())
                        return sr.getId();
                }
            }
        }
    	return contactId;    
    }
}