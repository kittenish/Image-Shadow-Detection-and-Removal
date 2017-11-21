MATLAB Deployment Checklist
===========================

Before you deploy your application, component, or library,
use this checklist to ensure you create a complete deployment package.
You can distribute a MATLAB Compiler-generated standalone
application, component, or library to any target machine with 
the same operating system as the machine on which 
the application was compiled (the "source" development machine).

For more information, see the documentation for the MATLAB Compiler at:
http://www.mathworks.com/access/helpdesk/help/toolbox/compiler/

NOTE: Items enclosed in angle brackets ( < > ) are variables.

1. Ensure that the MATLAB Component 
   Runtime (MCR) is installed on target machines, and ensure you
   have installed the correct version. To verify this, do the following: 
	
	A. Attempt to verify the MCR exists on your system.
           The MCR usually resides in these locations on these platforms:   
	 
        Operating System                Path to MCR
        ================                ===========
        Windows 	   C:\Program Files\MATLAB\MATLAB Component Runtime\v76
        Mac/Intel Mac      Applications/MATLAB/MATLAB_Component_Runtime/ 
        Linux              *** No predetermined installation location ***
                           Contact your system administrator.  

         *IMPORTANT: Always attempt to locate an existing MCR on your 
                     system before using the BUILDMCR command to create
                     an MCR. If you must create an MCR, see the Compiler
                     documentation for more details
     
        B. MATLAB 2007a uses MCR version 7.6. To verify
	the version number of the installed MCR, type the following command:
            [mcrmajor,mcrminor]=mcrversion
	at the MATLAB command prompt.
	 
						
2. Add the MCR directory to the path specified by the target system's 
   environment variable. 
	
	A. Locate the name of the environment variable to set, using the 
           table below:  

              Operating System      Environment Variable
              ================      ====================
		   Windows 	           PATH    
                   Linux	      LD_LIBRARY_PATH
		   Solaris            LD_LIBRARY_PATH    
                   Mac               DYLD_LIBRARY_PATH                 

 	B. Set the path by doing one of the following:

		On Windows systems:

		*  Add the MCR directory to the environment variable by opening a 
		   command prompt and issuing the DOS command:

  			set PATH=C:\Program Files\MATLAB\MATLAB Component
			Runtime\v76;%PATH% 

                   or, add:

                        C:\Program Files\MATLAB\MATLAB Component Runtime\v76
                  
                   to the PATH environment variable by doing the following:

			1. Select the My Computer icon on your desktop.
			2. Right-click the icon and select Properties from the menu.
			3. Select the Advanced tab.
			4. Click Environment Variables. 
		   Your environment variables are listed. 

		On UNIX systems:
		
		* Add the MCR directory to the environment variable by issuing 
		  this command:
 	
			setenv PATH /<matlabroot>/v76:"$PATH"

		  To make this change persistent after logout on UNIX machines, 
		  modify the .cshrc file to include this setenv command.
        
         NOTE: On Windows, the Environment Variable syntax utilizes 
               backslashes (\), delimited by semi-colons (;). On UNIX,
	       the EV syntax utilizes forward
               slashes (/), delimited by colons (:). 
	 NOTE: When deploying C and C++ standalone applications, it is possible
               to run the shell script file run_edison_wrapper.sh on UNIX and Mac
               instead of setting environment variables. See "Requirements
               for Standalone Applications," below.    
	

3. Create packages that contain the following files, based on what
   you are deploying: 

        Requirements for Standalone Applications:
        =========================================
  
	All Platforms:
		* edison_wrapper.ctf (Component Technology File archive,
		  platform-dependent on target machine)
			
	Windows:
		* MCRInstaller.exe (self-extracting MATLAB Component Runtime
		  library archive)  
		* edison_wrapper.exe (application created by MATLAB Compiler)
	UNIX:
		* MCRInstaller.zip (MATLAB Component Runtime library 
	 	  archive - manual unzip required)
		* edison_wrapper (application created by MATLAB Compiler)
		* run_edison_wrapper.sh (shell script that can be run 
                  to temporarily set environment paths and execute the application)

 	
        Requirements for C and C++ shared libraries:
        ============================================================

	All Platforms:            
		* edison_wrapper.so (shared library, file extension 
		  varies by platform)
		* edison_wrapper.h (library header file)
		* edison_wrapper.ctf (Component Technology File archive,
		  platform-dependent on target machine)
	
	Windows:
		* MCRInstaller.exe (self-extracting MATLAB Component Runtime
		  library archive)  
		
	UNIX:
		* MCRInstaller.zip (MATLAB Component Runtime library 
	 	  archive - manual unzip required)
		* unzip (optional utility to unzip MCRInstaller.zip)	
	
	

       Requirements for .NET Components (Windows only):
       ================================================

	* edison_wrapper.ctf (Component Technology File archive)	
	* edison_wrapper.xml (documentation files)
	* edison_wrapper.pdb (program database file - if 
	  DEBUG option selected)
	* edison_wrapper.dll (component assembly file)
	* MCRInstaller.exe (self-extracting MATLAB Component Runtime
	  library archive)  
		

       Requirements for COM Components (Windows only):
       ===============================================

	* edison_wrapper.ctf (Component Technology File archive)
	* edison_wrapper_1_0.dll (component containing 
	  compiled M-code)
	* _install.bat (script run by self-extracting executable)
	* MCRInstaller.exe (self-extracting MATLAB Component Runtime
	  library archive)  	
		

        Requirements for Java Components (All Platforms):
        =================================================

	* edison_wrapper.jar (Java archive containing Java 
	  interface to M-code in edison_wrapper.ctf)
	* edison_wrapper.ctf (Component Technology File archive,
	  platform-dependent on target machine)


        Requirements for COM Components for Use with Microsoft Excel (Windows only):
        ============================================================================

	* edison_wrapper_1_0.dll (component containing 
	  compiled M-code)
	* edison_wrapper.ctf (Component Technology File archive)
	* _install.bat (script run by self-extracting executable)
	* <add_in_file>.xla (Excel add-ins found in:
	  \distrib directory)  
	* MCRInstaller.exe (self-extracting MATLAB Component Runtime
	  library archive)  	

	
