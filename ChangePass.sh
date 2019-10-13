#!/bin/bash
#
####################################################################################################
#
# Description
#   This script will set the password for a specified account
#   and then Deletes the Login Keychain to avoid issues with the Keychain password not matching
#
####################################################################################################
#
# Notes: Does not require knowledge of previous password.
#
# Requires the following parameters be set.
#     ! setUsername: $4
#     ! setPassword: $5
#     ! setMANusername: $6
#     ! setManpassword: $7
#
####################################################################################################
#
#   DEFINE VARIABLES & READ IN PARAMETERS
#
####################################################################################################
#
ScriptName="ZZ 21 - Management - Local Account Password Change"
#
####################################################################################################
#
#   Checking and Setting Variables Complete
#
####################################################################################################

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
# Section End Function
#
VarCheck(){
#



# Outputs a blank line for reporting purposes
echo
#
# Check that the required variables are set
echo Checking that the required Variables are set
#
# Outputting a Blank Line for Reporting Purposes
echo
#
if [ -n "${4}" ]; then
    setUsername="${4}"
else
    echo 'This script requires a username.'
    #
	# Outputs a blank line for reporting purposes
	echo
	#
	Echo Ending Script '"'$ScriptName'"'
	#
	# Outputting a Blank Line for Reporting Purposes
	echo
	#
	# Outputting a Dotted Line for Reporting Purposes
	echo  -----------------------------------------------
	#
	# Outputting a Blank Line for Reporting Purposes
	echo
    exit 1
fi
#
if [ -n "${5}" ]; then
    setPassword="${5}"
else
    echo 'This script requires a password.'
	#
	# Outputs a blank line for reporting purposes
	echo
	#
	Echo Ending Script '"'$ScriptName'"'
	#
	# Outputting a Blank Line for Reporting Purposes
	echo
	#
	# Outputting a Dotted Line for Reporting Purposes
	echo  -----------------------------------------------
	#
	# Outputting a Blank Line for Reporting Purposes
	echo
	exit 1
fi
#
if [ -n "${6}" ]; then
    setMANusername="${6}"
else
    echo 'This script requires an Admin Account Username.'
    #
	# Outputs a blank line for reporting purposes
	echo
	#
	Echo Ending Script '"'$ScriptName'"'
	#
	# Outputting a Blank Line for Reporting Purposes
	echo
	#
	# Outputting a Dotted Line for Reporting Purposes
	echo  -----------------------------------------------
	#
	# Outputting a Blank Line for Reporting Purposes
	echo
    exit 1
fi
#
if [ -n "${7}" ]; then
    setMANpassword="${7}"
else
    echo 'This script requires an Admin Account Password.'
	#
	# Outputs a blank line for reporting purposes
	echo
	#
	Echo Ending Script '"'$ScriptName'"'
	#
	# Outputting a Blank Line for Reporting Purposes
	echo
	#
	# Outputting a Dotted Line for Reporting Purposes
	echo  -----------------------------------------------
	#
	# Outputting a Blank Line for Reporting Purposes
	echo
	exit 1
fi
#
PASSWORDCHECK=$(/usr/bin/dscl /Local/Default -authonly $setUsername $setPassword)
#
# Check that the required variables are set
echo Required Variables appear to be set
#


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
echo
#



VarCheck






echo Checking if Password needs changing
#
# Outputting a Blank Line for Reporting Purposes
echo
#
if [ "$PASSWORDCHECK" != "" ]
	then
		echo "Current Password for $setUsername does not match desired password, resetting"
		#
        # Outputting a Blank Line for Reporting Purposes
		echo
		#
		# Outputting a Dotted Line for Reporting Purposes
		echo  -----------------------------------------------
		#
		# Outputting a Blank Line for Reporting Purposes
		echo
		#
		# Outputting a Blank Line for Reporting Purposes
		echo
		#
		if [ "$(fdesetup list | grep -ic "^${setUsername},")" -eq '0' ]
			then
				echo User $setUsername is not FileVault Enabled
				UserFDE=NO
			else    
				echo User $setUsername is FileVault Enabled
				UserFDE=YES
		fi
		#
		# Outputting a Blank Line for Reporting Purposes
		echo
		#
		# Set the password as root.
		echo Setting the password as root for user $setUsername
		#
		dscl . passwd "/Users/${setUsername}" $setPassword
		#
		# Outputting a Blank Line for Reporting Purposes
		echo
		#
		# Outputs User Whose Keychains We Are Going To Delete
		#
		echo Deleting Keychains for user $setUsername
		#
		rm -f -r /Users/$setUsername/Library/Keychains
		#
		# Outputs a blank line for reporting purposes
		echo
		#
		if [ "$UserFDE" == "YES" ]
			then
				os_ver=$(sw_vers -productVersion)
				IFS='.' read -r -a ver <<< "$os_ver"
				echo OS Version = $os_ver
				# Outputting a Blank Line for Reporting Purposes
				echo
				if [[ "${ver[1]}" -ge 13 ]]
					then
						# Set it again as the user to update FileVault.
						echo "Setting Password again as the user to update FileVault (High Sierra or Higher)."
						# Outputs a blank line for reporting purposes
						echo
						#
						if [ "$setMANusername" == "JAMF" ]
							then
								#
								# Outputting a Dotted Line for Reporting Purposes
								echo  -----------------------------------------------
								#
								# Outputting a Blank Line for Reporting Purposes
								echo
								#
								echo Triggering Policy to set JAMF account to a known non-complex Password
								#
								sudo /usr/local/bin/jamf policy -trigger JAMF-NonComplex
								# Outputting a Blank Line for Reporting Purposes
								echo
								# Outputting a Dotted Line for Reporting Purposes
								echo  -----------------------------------------------
								#
								# Outputting a Blank Line for Reporting Purposes
								echo
								#
						fi
						#
						echo Changing password again to ensure updating filevault and Secure Token
						#
						# Outputs a blank line for reporting purposes
						echo
						sysadminctl -adminUser ${setMANusername} -adminPassword ${setMANpassword} -resetPasswordFor ${setUsername} -newPassword $setPassword 
						#
						# Outputting a Blank Line for Reporting Purposes
						echo
						#
						if [ "$setMANusername" == "JAMF" ]
							then
								#
								# Outputting a Dotted Line for Reporting Purposes
								echo  -----------------------------------------------
								#
								# Outputting a Blank Line for Reporting Purposes
								echo
								#
								echo Triggering Policy to set JAMF account to an unknown complex Password
								#
								sudo /usr/local/bin/jamf policy -trigger JAMF-Complex
								#
								# Outputting a Blank Line for Reporting Purposes
								echo
								#
						fi
						#
				elif [[ "${ver[1]}" -lt 13 ]]
					then
						# Set it again as the user to update FileVault.
						echo "Setting Password again as the user to update FileVault (Pre High Sierra)."
						sudo -iu ${setUsername} dscl . passwd "/Users/${setUsername}" $setPassword $setPassword
				fi
				#
			else    
				# Not going to set it again as the user as account is not Enabled for FileVault.
				echo Not going to set it again as the user as account is not Enabled for FileVault.
		fi
		#
	else
		echo "Current Password for $setUsername matches desired password, nothing to do"
fi
#
# Outputting a Blank Line for Reporting Purposes
echo
#
# Outputting a Dotted Line for Reporting Purposes
echo  -----------------------------------------------
#
# Outputting a Blank Line for Reporting Purposes
echo
#
echo Ending Script '"'$ScriptName'"'
#
# Outputting a Blank Line for Reporting Purposes
echo
#
# Outputting a Dotted Line for Reporting Purposes
echo  -----------------------------------------------
#
# Outputting a Blank Line for Reporting Purposes
echo
