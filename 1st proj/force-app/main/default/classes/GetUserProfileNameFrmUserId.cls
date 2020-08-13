/***************************************************************************************************
@Created By :      Bhagyashree B
@Created Date:     Jan 9 2020
@Description:      apex class called to fetch the logged in profile name for wizard
**********************************************************************************************************/
public class GetUserProfileNameFrmUserId {
    
    @InvocableMethod(label='InvokeApexFromFlowToGetProfileName')
    public static List<String> getUserInfo(List<User> lstUser) 
    {   
        List<String> ProfileNames=new List<String>();
        Set<ID> UserIds=new Set<ID>();
        for(User curUser:lstUser){
            UserIds.add(curUser.Id);
        }
        for(User currentUser:[Select Id,Profile.Name from User where Id IN : UserIds]){
            ProfileNames.add(currentUser.Profile.Name);
        }
        return ProfileNames;
    }   
}