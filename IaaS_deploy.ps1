# End to end sample for xWebAdministration  
  
configuration Sample_EndToEndxWebAdministration 
{ 
	param ($vmName)
    Import-DscResource -Module xWebAdministration 
	Node $vmName
    { 
		
		WindowsFeature IIS 
        { 
            Ensure          = "Present" 
            Name            = "Web-Server" 
        } 
        # Install the ASP .NET 4.5 role 
        WindowsFeature AspNet45 
        { 
            Ensure          = "Present" 
            Name            = "Web-Asp-Net45" 
        } 
		WindowsFeature WebServerManagementConsole
		{
        Name = "Web-Mgmt-Console"
        Ensure = "Present"
		}
        # Stop an existing website (set up in Sample_xWebsite_Default) 
        xWebsite DefaultSite  
        { 
            Ensure          = "Present" 
            Name            = "Default Web Site" 
            State           = "Stopped" 
            PhysicalPath    = "C:\inetpub\wwwroot"
            DependsOn       = "[WindowsFeature]IIS" 
        } 
        # Create a Web Application Pool 
        xWebAppPool NewWebAppPool 
        { 
            Name   = "TestAppPool" 
            Ensure = "Present" 
            State  = "Started" 
        } 
  
        #Create a New Website with Port 
        xWebSite NewWebSite 
        { 
            Name   = "TestWebSite" 
            Ensure = "Present" 
            BindingInfo = MSFT_xWebBindingInformation 
                        { 
                            Port = "100" 
                        } 
            PhysicalPath = "C:\web\webSite" 
            State = "Started" 
            DependsOn = @("[xWebAppPool]NewWebAppPool") 
        } 
       
        #Create a new Web Application 
        xWebApplication NewWebApplication 
        { 
            Name = "TestWebApplication" 
            Website = "TestWebSite" 
            WebAppPool =  "TestAppPool" 
            PhysicalPath = "C:\web\webApplication" 
            Ensure = "Present" 
            DependsOn = @("[xWebSite]NewWebSite") 
        } 
  
        #Create a new virtual Directory 
        xWebVirtualDirectory NewVirtualDir 
        { 
            Name = "TestVirtualDir" 
            Website = "TestWebSite" 
            WebApplication =  "TestWebApplication" 
            PhysicalPath = "C:\web\virtualDir"
            Ensure = "Present" 
            DependsOn = @("[xWebApplication]NewWebApplication") 
        } 
  
        File CreateWebConfig 
        { 
         DestinationPath = "C:\web\webSite" + "\web.config" 
         Contents = "<?xml version=`"1.0`" encoding=`"UTF-8`"?> 
                        <configuration> 
                        </configuration>" 
                Ensure = "Present" 
         DependsOn = @("[xWebVirtualDirectory]NewVirtualDir") 
        } 
  
        xWebConfigKeyValue ModifyWebConfig 
        { 
          Ensure = "Present" 
          ConfigSection = "AppSettings" 
          KeyValuePair = @{key="key1";value="value1"} 
          IsAttribute = $false 
          WebsitePath = "IIS:\sites\" + "TestWebSite" 
          DependsOn = @("[File]CreateWebConfig") 
        } 
    } 
}