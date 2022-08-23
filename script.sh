#!/usr/bin/env bash

PRODUCT=$(rg --no-line-number 'product = "(.+)"' Jenkinsfile_CNP -or '$1')
COMPONENT=$(rg --no-line-number 'component = "(.+)"' Jenkinsfile_CNP -or '$1')

APP_NAME="${PRODUCT}-${COMPONENT}"
if [ -z "$COMPONENT" ]
then
  APP_NAME="${PRODUCT}"
fi

REPO_NAME_ONLY=${REPOSITORY/hmcts\//}

if [[ $REPO_NAME_ONLY == a* ]] || [[ $REPO_NAME_ONLY == b* ]] || [[ $REPO_NAME_ONLY == c* ]]
then
  JENKINS_FOLDER_NAME=HMCTS_a_to_c
elif [[ $REPO_NAME_ONLY == d* ]] || [[ $REPO_NAME_ONLY == e* ]] || [[ $REPO_NAME_ONLY == f* ]] || [[ $REPO_NAME_ONLY == g* ]] || [[ $REPO_NAME_ONLY == h* ]] || [[ $REPO_NAME_ONLY == i* ]]
then
  JENKINS_FOLDER_NAME=HMCTS_d_to_i
else
  JENKINS_FOLDER_NAME=HMCTS_j_to_z
fi

cat << EOF > catalog-info.yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: "${APP_NAME}"
  annotations:
    # This must match folder-name/job-name in Jenkins.
    jenkins.io/job-full-name: cft:$JENKINS_FOLDER_NAME/$REPO_NAME_ONLY
    github.com/project-slug: $REPOSITORY
  tags:
    - java
  links:
    - url: https://hmcts-reform.slack.com/app_redirect?channel=platops-help
      title: "#platops-help on Slack"
      icon: chat
spec:
  type: service
  lifecycle: production
  owner: dts_platform_operations
EOF

cat catalog-info.yaml