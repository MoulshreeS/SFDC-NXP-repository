public class contactExtensionClass{

    //this class extends the functionality back to contact button present on Pilot page 
    public string previousPage = ApexPages.currentPage().getParameters().get('Id');
    
    public contactExtensionClass(ApexPages.StandardController controller) {
           
    }

     
  
  public PageReference backToContact(){
        system.debug('previouspage' +previouspage);
        PageReference pg = new PageReference('/'+previouspage);
        pg.setRedirect(true);
        system.debug('page' +pg);
        return pg;
    }
}