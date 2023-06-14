#!/bin/bash
# ##################################################
# NOTE: this is the Docker optimized build script.
# Running this outside of specified Docker container may not yield expected results.
#
if [ "$#" -lt 2 ]; then
	echo "ERROR: Illegal number of params"
	exit 1
fi
echo "Starting the build for $1"

#### GLOBAL SETTINGS ########
# Workspace root directory
BUILDROOT="/build/workspace"

# JDK settings
JAVA_HOME="/usr/lib/jvm/java-openjdk"
PATH="$JAVA_HOME/bin:$PATH"

# Maven settings
MAVEN_OPTS="-Xmx2048m -XX:MaxPermSize=1024m"
M2_HOME="/build/tool/maven"
chmod +x $M2_HOME/bin/*
PATH="$PATH:$M2_HOME/bin"

# Set environment variables
export JAVA_HOME
export MAVEN_OPTS
export PATH
#### GLOBAL SETTINGS END ####

################## PARAMS #############################
BUILDNUM=$1			# TFS build label
REPOROOTBUILDDIR=$2
WORKSPACE="${BUILDROOT}/${REPOROOTBUILDDIR}"
################## PARAMS #############################

echo "BUILDNUM: ${BUILDNUM}"

## ---- Script body ----
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SCRIPTNAME=$(basename "${BASH_SOURCE[0]}")

echo "Starting ${SCRIPTDIR}/${SCRIPTNAME}"


cd $WORKSPACE

#rm *.jar  2>/dev/null && echo "all those files have been deleted............." || echo "you have already removed the files"

# Maven build
# display maven version information
mvn -ver 2>&1 | tee $WORKSPACE/build.log 

# update version in pom.xml to $BUILDNUM
mvn versions:set -f "${BUILDROOT}/pom.xml" -DnewVersion=$BUILDNUM 2>&1 | tee -a $WORKSPACE/build.log

# maven build
mvn -T 4 -e clean verify -f "${BUILDROOT}/pom.xml" 2>&1 | tee -a $WORKSPACE/build.log

# deploy
#if [ "$publish" ]; then
#	echo -e "publishing to artifactory"
#	mvn deploy -f "${BUILDROOT}/pom.xml" -Dinternal.repo.username=${SVC_USER} -Dinternal.repo.password="${SVC_PASSWORD}" 2>&1 | tee -a $WORKSPACE/build.log
#fi

if [ "$?" -ne "0" ]; then
	echo -e "ERROR: Maven build failed!"
	exit 1
fi

echo "List build JARs in BUILDROOT..."
dir=$BUILDROOT/target
for f in "$dir"/*; do
    basename "$f"
done

# Copy output
DROPFOLDERROOT="/ingbuild/CreditRiskGdbSasBatch"

DROPFOLDER=$DROPFOLDERROOT #assumes the ROOT is mounted to final droplocation else use this: $DROPFOLDERROOT/$BUILDNUM
echo "Preparing drop folder (${DROPFOLDER})"
if [ ! -e $DROPFOLDER ]; then
	mkdir $DROPFOLDER
	if [ "$?" -ne "0" ]; then
		echo -e "ERROR: drop folder preparation failed"
		exit 1
	fi
fi

echo "Copy output to ${DROPFOLDER}"
cp $WORKSPACE/*.log $DROPFOLDER
cp -r "$BUILDROOT/target/surefire-reports" $DROPFOLDER
cp $BUILDROOT/target/CreditRiskGdbSasBatch.jar $DROPFOLDER


###----


# Write build info to build.info file
cd $BUILDROOT
GITBRANCH=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')
GITURL=$(git remote -v | grep fetch | head -1 | cut -f2 | cut -d ' ' -f1)
cd $WORKSPACE
echo "BUILDNUM = $BUILDNUM" > "$DROPFOLDER/build.info"
echo "GITURL = $GITURL" >> "$DROPFOLDER/build.info"
echo "GITBRANCH = $GITBRANCH" >> "$DROPFOLDER/build.info"
echo -n "GIT Commit ID = " >> "$DROPFOLDER/build.info"
git rev-parse HEAD 2>&1>> "$DROPFOLDER/build.info"

# Validation
ERR=0
if ! ls $DROPFOLDER/*.jar 1> /dev/null 2>&1; then
	let "ERR++"
	echo -e "ERROR: .jar output missing in drop folder ${WORKSPACE}"
fi
if [ $ERR -ne 0 ]; then
	echo -e "ERRORS found during build."
	exit 1
fi

echo "End ${SCRIPTDIR}/${SCRIPTNAME} with no errors"
