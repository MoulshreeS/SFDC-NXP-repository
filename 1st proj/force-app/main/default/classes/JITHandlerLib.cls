/************************************************************************
@Created By :    Nisha Agrawal
@Created Date:   Oct 19, 2018
@Description:    Library class for SAML JIT Handler related functionality
****************************************************************************/
public class JITHandlerLib 
{
    public class JitException extends Exception{}
    
    public static String CUSTOMER_COMMUNITY_PERMISSIONS = 'Customer_Community_Permissions';
    
    public static String createCommunityNickName(String firstName, String lastName, String federationId)
    {
        List<String> lstNameOptions = new List<String>();
        lstNameOptions.add(firstName.substring(0,1) + lastName); //JSmith
        lstNameOptions.add(lastname + firstName.substring(0,1)); //SmithJ
        lstNameOptions.add(firstName + lastName.substring(0,1)); //JohnS
        
        if(lastName.length() > 1)
        { 
            lstNameOptions.add(firstName + lastName.substring(0,2)); //JohnSm 
        }
        if(lastName.length()  > 2)
        {      
            lstNameOptions.add(firstName + lastName.substring(0,3)); //JohnSmi
        }
        lstNameOptions.add(firstName + federationId.substring(2,5).toUppercase()); //JohnDX586
        lstNameOptions.add(firstName + federationId.substring(3,5).toUppercase()); //JohnX586F
                        
        String selectedNickName = '';
        
        Map<String, User> mapNicknameToUser = new Map<String, User>();
        for(User objUser : [SELECT Id, CommunityNickname 
                               FROM User WHERE CommunityNickname in : lstNameOptions])
        {
            mapNicknameToUser.put(objUser.CommunityNickname, objUser);
        }
        
        for(String nickName : lstNameOptions)
        {
            if(!mapNicknameToUser.containsKey(nickName))
            {
                selectedNickName = nickName;
                break;
            }
        }
        
        return selectedNickName;
    }
    
    public static String createAlias(Map<String, String> attributes, String firstName, String lastName)
    {
		String strAlias = '';
		if(attributes.containsKey('User.Alias')) 
		{
            strAlias = attributes.get('User.Alias');
        } 
        else 
        {
        	//Alias limit of 8 chars. Does not have to be unique.
            if(firstName == null) 
            {
				strAlias = lastName;
            } 
            else 
            {
                strAlias = firstName.substring(0,1) + lastName;
            }
            if(strAlias.length() > 8) 
            {
                strAlias = strAlias.substring(0, 8);
            }
        }        
        return strAlias;
    }
}