#!/bin/sh
# Script to merge release artifacts from feature to sprint directory

# Get source branch name from git command
if [ $pr_from_branch == 'origin/master' ]; then	
git_branch_local=$(echo $pr_from_branch | sed -e "s|origin/||g")	
fi 
git_branch_local=$(echo $pr_from_branch | sed -e "s|feature/||g")

# Get branch type to skip this for release branch
branch_type=$(echo $pr_to_branch |rev |cut -f 2 -d"/" |rev)

# Check if the target is not develop, release, and master. Do only for sprint branch
if [[ $pr_to_branch != 'feature/develop' && $branch_type != 'release' && $pr_to_branch != 'origin/master' ]]; then
echo "Update Release Artifacts: Started"
git_branch_target=$(echo $pr_to_branch |rev |cut -f 1 -d"/" |rev)

# Assign source and target release directory path
SOURCE_DIR="${WORKSPACE}/release/$git_branch_local"
TARGET_DIR="${WORKSPACE}/release/$git_branch_target"

if [[ ! -d "${TARGET_DIR}" ]]; then
    echo "Creating directory ${TARGET_DIR}..."
    mkdir -p "${TARGET_DIR}"
else
    echo "Release folder ${TARGET_DIR} exists..."
fi
for sourceFile in ${SOURCE_DIR}/*; do
    file="$(basename "$sourceFile")"
    targetFile="${TARGET_DIR}/${file}"
    if [[ ! -f "${TARGET_DIR}/${file}" ]]; then
		echo "# release/$git_branch_target" >> ${targetFile}
    fi
    echo ${targetFile}
    (cat ${sourceFile}; echo) >> ${targetFile}
    copyFile="copy_${file}"
    cat ${targetFile} > ${copyFile}
    awk '!seen[$0]++' ${sourceFile} ${copyFile} |sort |egrep -v "^#|^$|^ " > ${targetFile} 
    rm -f ${copyFile}
done
echo "Update Release Artifacts: Completed"
fi

# Navigate to project workspace and commit the updated release artifacts
# This will happen on Jenkins job itself, no script needed