#!/bin/bash
#
###############################################################################################################################################
#
# ABOUT THIS PROGRAM
#
#   This Script is designed for use in JAMF
#
#   - This script will ...
#       Set the password for a specified account
#       Deletes the Login Keychain to avoid issues with the Keychain password not matching
#       Checks if user is in FileVault and then updates filevault as well
#
###############################################################################################################################################
#
# Notes: Does not require knowledge of previous password.
#
# Requires the following parameters be set.
#     ! setUsername: $4
#     ! setPassword: $5
#     ! setMANusername: $6
#     ! setManpassword: $7
#
###############################################################################################################################################
#
# HISTORY
#
#   Version: 1.1 - 14/10/2019
#
#   - 13/03/2018 - V1.0 - Created by Headbolt
#
#   - 14/10/2019 - V1.1 - Updated by Headbolt
#                           More comprehensive error checking and notation
#
####################################################################################################
#
#   DEFINE VARIABLES & READ IN PARAMETERS
#
####################################################################################################
#
# Grab the username for user whose password we want to change from JAMF variable #4 eg. username
setUsername=$4
# Grab the new password for user whose password we want to change from JAMF variable #5 eg. password
setPassword=$5
# Grab the username for the admin user we will use to change the password from JAMF variable #6 eg. username
setMANusername=$6
# Grab the password for the admin user we will use to change the password from JAMF variable #7 eg. password
setMANpassword=$7
#
# Set the Trigger Name of your Policy to set the JAMF Management Account to a Known Password incase
# it is used for the Admin User from Variable #8 eg. JAMF-NonComplex
NonCOMP="JAMF-NonComplex"
#
# Set the Trigger Name of your Policy to set the JAMF Management Account to an unknown complex Password incase
# it is used for the Admin User from Variable #9 eg. JAMF-Complex
COMP="JAMF-Complex"
#
# Set the name of the script for later logging
ScriptName="append prefix here as needed - Local Account Password Change"
#
####################################################################################################
#
#   Checking and Setting Variables Complete
#
###############################################################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
###############################################################################################################################################
#
# Defining Functions
#
###############################################################################################################################################
#
# Variable Check Function
#
VarCheck(){
#
# Check that the required variables are set
/bin/echo Checking that the required Variables are set
#
# Outputting a Blank Line for Reporting Purposes
/bin/echo
#
if [ "$setUsername" == "" ]
	then
		/bin/echo 'This script requires a username.'
		#
		SectionEnd
		ScriptEnd
		#
		exit 1
fi
#
if [ "$setPassword" == "" ]
	then
		/bin/echo 'This script requires a password.'
		#
		SectionEnd
		ScriptEnd
		#
		exit 1
fi
#
if [ "$setMANusername" == "" ]
	then
		/bin/echo 'This script requires an Admin Account Username.'
		#
		SectionEnd
		ScriptEnd
		#
		exit 1
fi
#
if [ "$setMANpassword" == "" ]
	then
		/bin/echo 'This script requires an Admin Account Password.'
		#
		SectionEnd
		ScriptEnd
		#
		exit 1
fi
#
/bin/echo Required Variables appear to be set
#
}
#
###############################################################################################################################################
#
# Password Change Function
#
ChangePass(){
#
/bin/echo "Current Password for $setUsername does not match desired password, resetting"
#
SectionEnd
#
# Set the password as root.
/bin/echo Setting the password as root for user $setUsername
#
dscl . passwd "/Users/${setUsername}" $setPassword
#
# Outputting a Blank Line for Reporting Purposes
/bin/echo
#
# Outputs User Whose Keychains We Are Going To Delete
#
/bin/echo Deleting Keychains for user $setUsername
#
rm -f -r /Users/$setUsername/Library/Keychains
#
# Outputting a Blank Line for Reporting Purposes
/bin/echo
#
# Check FileVault Status for the User
#
if [ "$(fdesetup list | grep -ic "^${setUsername},")" -eq '0' ]
	then
		/bin/echo User $setUsername is not FileVault Enabled
	else    
		/bin/echo User $setUsername is FileVault Enabled
        SectionEnd
        FileVaultReset
fi
#
}
#
###############################################################################################################################################
#
# FileVault Reset Function
#
FileVaultReset(){
#
os_ver=$(sw_vers -productVersion)
IFS='.' read -r -a ver <<< "$os_ver"
#
/bin/echo OS Version = $os_ver
# Outputs a blank line for reporting purposes
/bin/echo
#
if [[ "${ver[1]}" -ge 13 ]]
	then
		# Set it again as the user to update FileVault.
		/bin/echo "Setting Password again as the user to update FileVault (High Sierra or Higher)."
		# Outputs a blank line for reporting purposes
		/bin/echo
        # Checks if the Admin user is the JAMF Management account
        #
		if [ "$setMANusername" == "JAMF" ]
			then
				SectionEnd
				# JAMF Management account is being used, this should be a Complex password not known to anyone
                # So we need to reset it to a know password so we can use it for this operation
                # Calling a policy to reset the JAMF account to match what we have put in the variable
                #
				/bin/echo Triggering Policy to set JAMF account to a known non-complex Password
				# Outputs a blank line for reporting purposes
				/bin/echo
				/usr/local/bin/jamf policy -trigger $NonCOMP
				# 
                SectionEnd
				#
		fi
		#
		/bin/echo Changing password again to ensure updating filevault and Secure Token
		#
		# Outputs a blank line for reporting purposes
		/bin/echo
		sysadminctl -adminUser ${setMANusername} -adminPassword ${setMANpassword} -resetPasswordFor ${setUsername} -newPassword $setPassword 
		#
		if [ "$setMANusername" == "JAMF" ]
			then
                SectionEnd
				#
				# JAMF Management account is being used, this should be a Complex password not known to anyone
				# but it was changed in a previous step to a known password
                # Calling a policy to reset the JAMF account to an unknown complex password
                /bin/echo Triggering Policy to set JAMF account to an unknown complex Password
   				# Outputs a blank line for reporting purposes
				/bin/echo
				#               
                /usr/local/bin/jamf policy -trigger $COMP
				#
		fi
		#
elif [[ "${ver[1]}" -lt 13 ]]
	then
		# Set it again as the user to update FileVault.
		/bin/echo "Setting Password again as the user to update FileVault (Pre High Sierra)."
		sudo -iu ${setUsername} dscl . passwd "/Users/${setUsername}" $setPassword $setPassword
fi
#
}
#
###############################################################################################################################################
#
# Section End Function
#
SectionEnd(){
#
# Outputting a Blank Line for Reporting Purposes
/bin/echo
#
# Outputting a Dotted Line for Reporting Purposes
/bin/echo  -----------------------------------------------
#
# Outputting a Blank Line for Reporting Purposes
/bin/echo
#
}
#
###############################################################################################################################################
#
# Script End Function
#
ScriptEnd(){
#
# Outputting a Blank Line for Reporting Purposes
#/bin/echo
#
/bin/echo Ending Script '"'$ScriptName'"'
#
# Outputting a Blank Line for Reporting Purposes
/bin/echo
#
# Outputting a Dotted Line for Reporting Purposes
/bin/echo  -----------------------------------------------
#
# Outputting a Blank Line for Reporting Purposes
/bin/echo
#
}
#
###############################################################################################################################################
#
# End Of Function Definition
#
###############################################################################################################################################
# 
# Begin Processing
#
####################################################################################################
#
# Outputting a Blank Line for Reporting Purposes
/bin/echo
#
SectionEnd
#
VarCheck
SectionEnd
#
/bin/echo Checking if Password needs changing
#
# Outputting a Blank Line for Reporting Purposes
/bin/echo
#
PASSWORDCHECK=$(/usr/bin/dscl /Local/Default -authonly $setUsername $setPassword 2>/dev/null)
#
if [ "$PASSWORDCHECK" != "" ]
	then
		ChangePass
	else
		/bin/echo "Current Password for $setUsername matches desired password, nothing to do"
fi
#
SectionEnd
ScriptEnd
