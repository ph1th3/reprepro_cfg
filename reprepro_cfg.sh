#!/bin/bash

# Extrait le paragraphe contenant la ligne sSearchLine
search_paragraph() {
	local sSourceFilename=${1:-}
	local sSearchLine=${2:-}
	awk -v RS= '/\n'"${sSearchLine}"'\n/' "${sSourceFilename}"
}

# Supprime le paragraphe contenant la ligne sSearchLine
delete_paragraph() {
	local sSourceFilename=${1:-}
	local sSearchLine=${2:-}
	local sFileTmp=$(mktemp)
	awk -v RS= -v ORS='\n\n' '!/'"${sSearchLine}"'/' "${sSourceFilename}" > "${sFileTmp}"
	cp "${sFileTmp}" "${sSourceFilename}"
	rm -f "${sFileTmp}"
}

# Ajoute le contenu du fichier sTmpFilename au fichier sSourceFilename
add_paragraph() {
	local sSourceFilename=${1:-}
	local sTmpFilename=${2:-}
	cat "${sTmpFilename}" >> "${sSourceFilename}"
	echo >>"${sSourceFilename}"
	rm -f "${sTmpFilename}"
}

# Extrait le paragraphe contenant le pattern sPattern dans sSourceFilename, 
# si le paragraphe est différent du contenu de la fonction sFonction, 
# alors suppression du paragraphe et ajout du nouveau généré par la fonction
paragraph_compare() {
	local sPattern=${1:-}
	local sSourceFilename=${2:-}
	local sFonction=${3:-}
	local sFileTmp1=$(mktemp)
	local sFileTmp2=$(mktemp)
	search_paragraph "${sSourceFilename}" "${sPattern}" > "${sFileTmp1}"
	"${sFonction}" > "${sFileTmp2}"
	if ! diff "${sFileTmp1}" "${sFileTmp2}" ; then
		delete_paragraph "${sSourceFilename}" "${sPattern}"
		add_paragraph "${sSourceFilename}" "${sFileTmp2}"
	fi
	rm -f "${sFileTmp1}" "${sFileTmp2}"
}

DistributionBuster() {
cat <<EOF
Origin: Debian
Label: Debian
Version: 10.6
Suite: stable
Update: buster
Codename: buster
Architectures: amd64
Components: main contrib
Description: Your description
SignWith: yes
EOF
}

UpdateBuster() {
cat<<EOF
Name: buster
Method: http://ftp.fr.debian.org/debian/
Suite: buster
Components: main
Architectures: amd64
VerifyRelease: blindtrust
FilterList: hold listeblanche
#FilterFormula: Priority (==required)
EOF
}

DistributionBusterUpdates() {
cat <<EOF
Origin: Debian
Label: Debian
Version: 10.6
Suite: stable
Update: buster-updates
Codename: buster-updates
Architectures: amd64
Components: main contrib
Description: Your description
SignWith: yes
EOF
}

UpdateBusterUpdates() {
	cat<<EOF
Name: buster-updates
Method: http://ftp.fr.debian.org/debian/
Suite: buster
Components: main
Architectures: amd64
VerifyRelease: blindtrust
FilterList: hold listeblanche
#FilterFormula: Priority (==required)
EOF
}

DistributionBullseye() {
cat <<EOF
Origin: Debian
Label: Debian
Suite: testing
Update: bullseye
Codename: bullseye
Architectures: amd64
Components: main contrib
Description: Debian x.y Testing distribution - Not Released
SignWith: yes
EOF
}

UpdateBullseye() {
	cat<<EOF
Name: bullseye
Method: http://ftp.fr.debian.org/debian/
Suite: testing
Components: main
Architectures: amd64
VerifyRelease: blindtrust
FilterList: hold listeblanche
#FilterFormula: Priority (==required)
EOF
}

DistributionBullseyeUpdates() {
cat <<EOF
Origin: Debian
Label: Debian
Suite: testing
Update: bullseye-updates
Codename: bullseye-updates
Architectures: amd64
Components: main contrib
Description: Your description
SignWith: yes
EOF
}

UpdateBullseyeUpdates() {
	cat<<EOF
Name: bullseye-updates
Method: http://ftp.fr.debian.org/debian/
Suite: testing
Components: main contrib
Architectures: amd64
VerifyRelease: blindtrust
FilterList: hold listeblanche
#FilterFormula: Priority (==required)
EOF
}

sDistributionFilename=/tmp/distributions
sUpdateFilename=/tmp/updates

paragraph_compare "Codename: buster" "${sDistributionFilename}" "DistributionBuster"
paragraph_compare "Name: buster" "${sUpdateFilename}" "UpdateBuster"

paragraph_compare "Codename: buster-updates" "${sDistributionFilename}" "DistributionBusterUpdates"
paragraph_compare "Name: buster-updates" "${sUpdateFilename}" "UpdateBusterUpdates"

paragraph_compare "Codename: bullseye" "${sDistributionFilename}" "DistributionBullseye"
paragraph_compare "Name: bullseye" "${sUpdateFilename}" "UpdateBullseye"

paragraph_compare "Codename: bullseye-updates" "${sDistributionFilename}" "DistributionBullseyeUpdates"
paragraph_compare "Name: bullseye-updates" "${sUpdateFilename}" "UpdateBullseyeUpdates"

exit  

