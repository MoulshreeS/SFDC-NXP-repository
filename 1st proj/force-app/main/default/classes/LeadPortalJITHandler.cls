/*********************************************************************************************************
@Created By:		Nisha Agrawal
@Created Date:		Oct 06, 2018
@Description:		JIT Handler for Lead Portal Partner community.
--------------------------------------------------------------------
@Modified By:		Nisha Agrawal
@Modified Date:		Oct 06, 2018
@Description:		Modified to include scenario when user already exists as customer community user 
					and need access to Lead Portal
***********************************************************************************************************/

//This class provides logic for inbound just-in-time provisioning of single sign-on users in your Salesforce organization.
global class LeadPortalJITHandler implements Auth.SamlJitHandler 
{
    global User createUser(Id samlSsoProviderId, Id communityId, Id portalId, String federationIdentifier, 
                           Map<String, String> attributes, String assertion) 
    {        
        String email = null;
        
        if(attributes.containsKey('User.Email')) 
        {
            email = attributes.get('User.Email');
        }

        boolean createUser = true;
        User objUser;

        List <User> lstUsers;
        
        //check if user already exist. first check by federation id and email (email in username)
        if(federationIdentifier != null && String.isBlank(federationIdentifier) == false)
        {
            lstUsers = [SELECT Id, Name, Alias, Email, CommunityNickname, FederationIdentifier, AccountId, ContactId , CompanyName, ProfileId
							FROM User WHERE IsActive = true AND Federationidentifier =: federationIdentifier];    
        	if(lstUsers.size() > 0)
            {
                
                objUser = lstUsers[0];
                createUser = false;
            }
        }
        //User not found by federationId
        if(objUser == null && email != null) 
        {
            lstUsers = [SELECT Id, Name, Alias, Email, CommunityNickname, FederationIdentifier, AccountId, ContactId , CompanyName, ProfileId
						FROM User WHERE IsActive = true AND UserName =: email ];    
        
        	if(lstUsers.size() > 0)
            {
                objUser = lstUsers[0];
                createUser = false;
            }
        }
        
        objUser = handleJit(createUser, objUser, samlSsoProviderId, portalId, communityId, federationIdentifier, attributes, assertion);
               
        return objUser;
    }

    global void updateUser(Id userId, Id samlSsoProviderId, Id communityId, Id portalId, 
                           String federationIdentifier, Map<String, String> attributes, String assertion) 
    {
        List<User> lstUsers = [SELECT Id, Name, Alias, Email, CommunityNickname, FederationIdentifier, AccountId, ContactId, CompanyName, Country , ProfileId  
                  				FROM User WHERE Id =: userId];
        if(lstUsers.size() > 0)
        {
        	handleJit(false, lstUsers[0], samlSsoProviderId, portalId, communityId, federationIdentifier, attributes, assertion);    
        }
    }
    
    private User handleJit(boolean create, User u, Id samlSsoProviderId, Id portalId, Id communityId, 
                           String federationIdentifier, Map<String, String> attributes, String assertion) 
    {
        Contact objContact = handleContact(u, attributes);
        if(objContact != null)
        {
        	u = handleUser(create, u, objContact.Id, attributes, federationIdentifier);    
        	updateContact(JSON.serialize(objContact));
        }
		
        return u;
    }    
    
    private User handleUser(boolean create, User objUser, String contactId, Map<String, String> attributes, String federationIdentifier) 
    {
        LeadPortalLib.getExternalUserProfile();
        Id partnerUserProfileId = LeadPortalLib.LP_EXTERNAL_PROFILE_Id;        
        
        //get the profile id for this user
        if(partnerUserProfileId == null)
        {
            throw new JITHandlerLib.JitException('Error Occured : Profile Not found.');
        }
        
        if(create)
        {
            objUser = new User(ProfileId = partnerUserProfileId, ContactId = contactId, Disti_Lead_Portal_User_Role__c = 'User', EmailEncodingkey='ISO-8859-1', LanguageLocaleKey='en_US', LocaleSidKey='en_US', TimeZoneSidKey='GMT');
            //set the username
            if(attributes.containsKey('User.Email')) 
			{
				objUser.Username = attributes.get('User.Email');
			}
        }
        
        if(attributes.containsKey('User.Email')) 
        {
            objUser.Email = attributes.get('User.Email');
        } 
        
        if(attributes.containsKey('User.FirstName')) 
        {
            objUser.FirstName = attributes.get('User.FirstName');
        }
                
        if(attributes.containsKey('User.LastName')) 
        {
            objUser.LastName = attributes.get('User.LastName');
        }
        
        if(attributes.containsKey('User.CompanyName')) 
        {
            objUser.CompanyName = attributes.get('User.CompanyName');
        }
                
        if(attributes.containsKey('User.Country')) 
        {
            objUser.Country = attributes.get('User.Country');
        }
        
        if(objUser.FederationIdentifier == null || objUser.FederationIdentifier.trim().length() == 0)
        {
            if(federationIdentifier != null && federationIdentifier.trim().length() > 0) 
            {
                objUser.FederationIdentifier = federationIdentifier;  
            }
        }
        
        if(objUser.CommunityNickname == null || objUser.CommunityNickname.trim().length() == 0)
        {
            objUser.CommunityNickname = JITHandlerLib.createCommunityNickName(objUser.FirstName, objUser.LastName, objUser.FederationIdentifier);
        }
        if(objUser.Alias == null || objUser.Alias.trim().equals(''))
        {
            objUser.Alias = JITHandlerLib.createAlias(attributes, objUser.FirstName, objUser.LastName);
        }

        if(!create) 
        {
            //check the profileid for existing user - if customer community user then need to promote 
            if( objUser.ProfileId != partnerUserProfileId)
            {
                //update the profile
                CasePortalUtil.getCustomerCommunityUserProfile();
        		Id customerProfileId = CasePortalUtil.CUSTOMER_COMMUNITY_USER_PROFILE_ID;
                
                if(customerProfileId != null && objUser.ProfileId == customerProfileId)
                {
                    if(! Test.isRunningTest()) //changing the profile from different license is not allowed somehow in test context
                    {
                    	objUser.ProfileId = partnerUserProfileId;        
                    }                    
                    objUser.Disti_Lead_Portal_User_Role__c = 'User';
                }                
            }
            
            system.debug('===objUser : ' + objUser);
            
            //calling method from MixedDMLOps class to avoid mixed DML issue in test class context
            MixedDMLOps.up(new List<User>{objUser});            
        }
        
        return objUser;
    }
    
    private Contact handleContact(User objUser, Map<String, String> attributes) 
    {    
        Contact objContact = null;
        
        if(objUser != null && objUser.ContactId != null)
        {
            objContact = [SELECT Id, AccountId FROM Contact WHERE Id =: objUser.ContactId];
        }
		//if no contact found, then check if a contact exist by email		      
        if(objContact == null)
        {
			if(attributes.containsKey('User.Email')) 
            {
                String contactEmail = attributes.get('User.Email');
                List<Contact> lstContacts = [Select Id, AccountId From Contact Where Email =: contactEmail order by LastModifiedDate DESC];
                if(lstContacts.size() > 0)
                {
                    objContact = lstContacts[0];
                }
            }
        }
    
        if(objContact != null)
        {
            if(attributes.containsKey('User.Email')) 
            {
                objContact.Email = attributes.get('User.Email');
            }
            if(attributes.containsKey('User.FirstName')) 
            {
                objContact.FirstName = attributes.get('User.FirstName');
            }
            if(attributes.containsKey('User.LastName')) 
            {
                objContact.LastName = attributes.get('User.LastName');
            }
            if(attributes.containsKey('User.CompanyName')) 
            {
                objContact.Company__c = attributes.get('User.CompanyName');
            }
            if(attributes.containsKey('User.Country')) 
            {
                objContact.Community_web_country__c = attributes.get('User.Country');
            }
            //set active community user flag as true
            objContact.Is_Active_Community_User__c = true;
            //set new checkbox to false here
            objContact.Not_Found_In_Marketing__c = false;
            
            return objContact;
        }
        return null;
    }
    
	@future
    private static void updateContact(String contactAsJSON)
	{
        try
        {
            Contact objContact = (Contact)JSON.deserialize(contactAsJson, Contact.class);
           	update objContact;            
        } 
        catch(Exception e)
        {
            throw new JITHandlerLib.JitException('EXCEPTION WHILE UPDATING CONTACT: ' + e.getMessage());            
        }
	}
}