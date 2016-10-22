#!/bin/bash

declare -A logslist=(
     ["Apache"]="/var/logs/apache2/access.log"
     ["Mongo"]="/var/logs/mongodb/mongod.log"
     ["MySQL"]="/var/logs/mysql/error.log"
     ["TomCat"]="/var/log/tomcat8/catalina.out"
   )
