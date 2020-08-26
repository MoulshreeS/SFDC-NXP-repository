public class DuplicateInviteeCheck {
	@InvocableMethod(label='CheckInviteeDuplicates')
    public static List<String> getUserInfo(List<List<Project_Team__c>> lstUser) 
    {
      
       List<String> var =new List<String>(); 
       Integer Count=0;
       String flag='false';
       String currentInviteemailId;
        try{
      
        for(List<Project_Team__c> Invitee:lstUser)
        {
          
            for(Project_Team__c currentInvitee:Invitee ){
               if(Count ==0)
               {
                   currentInviteemailId =currentInvitee.Email_Address__c;
               }
               else
                {
                    if(currentInviteemailId == currentInvitee.Email_Address__c)
                    {
                        flag ='true';
                        break;
                    }
                }
                Count++;
            }
           
        }
       var.add(flag);
                  
        }catch(Exception e){
             system.debug('The exception is caught'+ e.getMessage());
        }
       return var;
    }
}