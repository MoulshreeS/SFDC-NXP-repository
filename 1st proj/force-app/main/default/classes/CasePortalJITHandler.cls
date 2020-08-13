/*********************************************************************************************************
@Created By:		Nisha Agrawal
@Created Date:		Aug 09, 2019
@Description:		JIT Handler for Case Portal Lightning Community
***********************************************************************************************************/

//This class provides logic for inbound just-in-time provisioning of single sign-on users in your Salesforce organization.
global class CasePortalJITHandler implements Auth.SamlJitHandler 
{
    @testvisible
    private static final String ACCOUNT_NAME = 'NXP Community';
    @testvisible
    private static final String ERROR_INTERNAL_USER_NOT_EXISTS = 'You are a NXP Employee so please register first with self registration page to access the portal ';
    
    global User createUser(Id samlSsoProviderId, Id communityId, Id portalId,
        					String federationIdentifier, Map<String, String> attributes, String assertion) 
    {
        String strEmail = null;
        
        if(attributes.containsKey('User.Email')) 
        {
            strEmail = attributes.get('User.Email');
        }

        system.debug('==strEmail :' + strEmail);
        boolean createUser = true;
        User objUser;
        
        List<User> lstUsers;
        
        //check if user already exist. first check by federation id, if not found then check by email
        if(federationIdentifier != null && String.isBlank(federationIdentifier) == false)
        {
            lstUsers = [SELECT Id, Name, Alias, Email, CommunityNickname, FederationIdentifier, AccountId, ContactId, ProfileId FROM User 
                        WHERE IsActive = true AND Federationidentifier=: federationIdentifier];
            
        	if(lstUsers.size() > 0)
            {    
                createUser = false;
                objUser = lstUsers[0];
            }
        }        
        
        //User not found by federationId
        if(objUser == null && strEmail != null) 
        {
            //check by username instead of email as username should be an email and always unique
            lstUsers = [SELECT Id, Name, Alias, Email, CommunityNickname, FederationIdentifier, AccountId, ContactId, ProfileId 
                        FROM User WHERE IsActive = true AND UserName =: strEmail];
            if(lstUsers.size()>0)
            {
                createUser = false;
                objUser = lstUsers[0];
            }
        }

        //check if nxp internal user and user does not exists
        if(objUser == null && strEmail !=null && strEmail.tolowercase().contains('nxp.com'))
        {
            throw new JITHandlerLib.JitException(ERROR_INTERNAL_USER_NOT_EXISTS);
        }
        else
        {
        	objUser = handleJit(createUser, objUser, samlSsoProviderId, portalId, federationIdentifier, attributes, assertion);    
        }        

        return objUser;
    }

    global void updateUser(Id userId, Id samlSsoProviderId, Id communityId, Id portalId,
        					String federationIdentifier, Map<String, String> attributes, String assertion) 
	{
        User u = [SELECT Id, name, alias, email, CommunityNickname, FederationIdentifier, AccountId, ContactId, ProfileId  FROM User WHERE Id=:userId];
        handleJit(false, u, samlSsoProviderId, portalId,federationIdentifier, attributes, assertion);
    }

    private User handleJit(boolean create, User objUser, Id samlSsoProviderId, Id portalId,
        					String federationIdentifier, Map<String, String> attributes, String assertion) 
    {        
        Id accountId = handleAccount();
        Id contactId = handleContact(create, accountId, objUser, attributes);
        return handleUser(create, objUser, contactId, attributes, federationIdentifier);
    }
    
    private user handleUser(boolean create, User objUser, Id contactId, Map<String, String> attributes, String federationIdentifier) 
    {
        /* If you are updating Contact or Account object fields, you cannot update the following User fields at the same time.
         * If your identity provider sends these User fields as attributes along with Contact 
         * or Account fields, you must modify the logic in this class to update either these 
         * User fields or the Contact and Account fields.         * 
         * IsActive, ForecastEnabled, ProfileId, UserRoleId
         */

        String strEmail = ((attributes.containsKey('User.Email')) ? attributes.get('User.Email') : null) ;
        Id customerUserProfileId;
        
        CasePortalUtil.getCustomerCommunityUserProfile();
		//check if user has been invited for colloboration for any project
		List<Project_Team__c> lstInvites = [Select Id, Email_Address__c From Project_Team__c 
                                         	Where Email_Address__c = : strEmail and Status__c =: CasePortalUtil.PROJECT_TEAM_STATUS_INVITED];
        
        if(lstInvites.size() > 0)
        {
        	customerUserProfileId = CasePortalUtil.CUSTOMER_COMMUNITY_PLUS_PROFILE_Id; 
        }
        else
        {
            customerUserProfileId = CasePortalUtil.CUSTOMER_COMMUNITY_USER_PROFILE_ID;
        }
        
        if(customerUserProfileId == null)
        {
            throw new JITHandlerLib.JitException('Error Occured : Customer User Profile Not Found');
        }
        if(create)
        {
            objUser = new User(ContactId = contactId, EmailEncodingkey='ISO-8859-1', LanguageLocaleKey='en_US', LocaleSidKey='en_US', TimeZoneSidKey='GMT');
            objUser.ProfileId= customerUserProfileId;
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
        
        if(! create) 
        {
            //calling method from MixedDMLOps class to avoid mixed DML issue in test class context
            MixedDMLOps.up(new List<User>{objUser});            
            
			//check the profileid for existing user - if lead portal user then need to assign customer community user permissions 
            if(objUser.ProfileId != CasePortalUtil.CUSTOMER_COMMUNITY_USER_PROFILE_ID && objUser.ProfileId != CasePortalUtil.CUSTOMER_COMMUNITY_PLUS_PROFILE_Id )
            {
            	LeadPortalLib.getExternalUserProfile();
                Id partnerUserProfileId = LeadPortalLib.LP_EXTERNAL_PROFILE_Id;        
                
                //get the profile id for Lead Portal user
                if(partnerUserProfileId == null)
                {
                    throw new JITHandlerLib.JitException('Error Occured : Lead Portal User Profile Not found.');
                }
                
                if(partnerUserProfileId != null && objUser.ProfileId == partnerUserProfileId)
                {
                    List<PermissionSetAssignment> psa = [Select PermissionSetId,AssigneeId From PermissionSetAssignment 
                                                         	Where PermissionSet.Name=:JITHandlerLib.CUSTOMER_COMMUNITY_PERMISSIONS and AssigneeId =:objUser.Id];
                    if(psa==null || psa.isEmpty())
                    {
                        UserTriggerHandler.assignPermissionSetToUsers(new Set<Id>{objUser.Id});        
                    }                    	
                }                
            }
        }
        
        return objUser;
    }
    
    private String handleContact(boolean create, Id accountId, User objUser, Map<String, String> attributes)
    {
        Contact objContact;
        
        if(objUser != null && objUser.ContactId != null)
        {
            objContact = [SELECT Id, AccountId, Community_web_country__c FROM Contact WHERE Id =: objUser.ContactId];
        }
        
        //if no contact found, then check if contact exist by email
       	if(objContact == null)
        {
            if(attributes.containsKey('User.Email')) 
            {
                String contactEmail = attributes.get('User.Email');
                List<Contact> lstContacts = [Select Id, AccountId, Community_web_country__c From Contact Where Email =: contactEmail order by LastModifiedDate DESC];
                if(lstContacts.size() > 0)
                {
                    objContact = lstContacts[0];
                }
            }
        }
      
        if(objContact == null)
        {
            objContact = new Contact(AccountId = accountId);
        }
        
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
        if(attributes.containsKey('User.Country') && String.isNotBlank(attributes.get('User.Country')) ) 
        {
            objContact.Community_web_country__c = attributes.get('User.Country');
        }
		
		if(String.isBlank(objContact.Community_web_country__c))
        {
            objContact.Community_web_country__c = 'Unknown';    
        }
        
        //set active community user flag as true
        objContact.Is_Active_Community_User__c = true;
        //set new checkbox to false here
        objContact.Not_Found_In_Marketing__c = false;
        
        if(objContact.Id == null) 
        {
            insert objContact;
		} 
        else 
		{
           updateContact(JSON.serialize(objContact));
		}         
		return objContact.Id;
    }

    private Id handleAccount() 
    {
        List<Account> lstAccounts = [SELECT Id FROM Account WHERE Name =: ACCOUNT_NAME ];
        if(lstAccounts.size() > 0)
        {
        	return lstAccounts[0].Id;    
        }
        return null;
    }

	@future
    private static void updateContact(String contactAsJSON)
	{
        try
        {
            Contact objContact = (Contact)JSON.deserialize(contactAsJSON, Contact.class);
           	update objContact;            
        } 
        catch(Exception e)
        {
            throw new JITHandlerLib.JitException('EXCEPTION WHILE UPDATING CONTACT ' + contactAsJSON + ' : ' + e.getMessage());           
        }
	}    
}