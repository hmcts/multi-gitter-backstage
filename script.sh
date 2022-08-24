#!/usr/bin/env bash

PRODUCT=$(rg --no-line-number 'product = "(.+)"' Jenkinsfile_CNP -or '$1')
export PRODUCT

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

LANGUAGE=$(rg 'java' Jenkinsfile_CNP)

if rg 'java' Jenkinsfile_CNP > /dev/null
then
  LANGUAGE=java
else
  LANGUAGE=nodejs
fi

if echo "$REPOSITORY" | grep shared-infra
then
  APP_NAME="${PRODUCT}-shared-infrastructure"
  LANGUAGE=terraform
fi

JENKINS_INSTANCE=cft

if [ ! -f /tmp/team-config.yml ]
then
  wget https://raw.githubusercontent.com/hmcts/cnp-jenkins-config/master/team-config.yml -O /tmp/team-config.yml
fi

SLACK_CHANNEL=$(yq '.[env(PRODUCT)].slack.contact_channel' /tmp/team-config.yml)

OWNER=$(yq '.[env(PRODUCT)].azure_ad_group | downcase | sub(" ", "_")' /tmp/team-config.yml)

cat << EOF > catalog-info.yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: "${APP_NAME}"
  annotations:
    # This must match folder-name/job-name in Jenkins.
    jenkins.io/job-full-name: $JENKINS_INSTANCE:$JENKINS_FOLDER_NAME/$REPO_NAME_ONLY
    github.com/project-slug: $REPOSITORY
  tags:
    - ${LANGUAGE}
  links:
    - url: https://hmcts-reform.slack.com/app_redirect?channel=platops-help
      title: "${SLACK_CHANNEL} on Slack"
      icon: chat
spec:
  type: service
  lifecycle: production
  owner: $OWNER
EOF

#cat catalog-info.yaml
