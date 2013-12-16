#!/bin/bash
#
# Use GitHub's API to loop through every repo in an organization and add an email service hook
# Has multi-page support for repos, not orgs
# 
# Note: Auth token is read in from a separate file.
#
# To use with Mac
# Install jq to parse JSON response
# => brew install jq
#
# If you need to install brew
# => ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)"
#
# Derak Berreyesa
# derak.berreyesa@gmail.com
########################################################################

url="https://github.office.my_company.com/api/v3"
token=$( cat token.txt )
email="commits@my_company.com"

# Repo Types
repo_type[0]="public"
repo_type[1]="private"

token_cmd="Authorization: token $token"

all_orgs=$( curl -H "$token_cmd" "$url/user/orgs" | jq '.[].login' | sed 's/\"//g' )
echo $all_orgs

total_orgs=$( echo $all_orgs | sed 's/\"//g' | wc -w | sed 's/ //g' )
echo "total_orgs: $total_orgs"

# Do the same for all repo types
for t in "${repo_type[@]}"
do
  echo "Repo Type: $t"

  #total_orgs=1 #for testing
  for (( i=1; i<=$total_orgs; i++ ))
  do
    org=$( echo ${all_orgs[0]} | cut -f $i -d " " )
    echo "Org $i: $org"

    last_repo_page=$( curl --head -H "$token_cmd" "$url/orgs/$org/repos?type=$t" | grep rel=\\\"last\\\" | rev | cut -f 2 -d " " | rev | cut -f 2 -d "=" | sed 's/>;//g' | sed 's/&type//g' )
    echo "last_repo_page: $last_repo_page"

    if [ "$last_repo_page" == "" ]
    then
      all_repos=$( curl -H "$token_cmd" "$url/orgs/$org/repos?type=$t" | jq '.[].name' | sed 's/\"//g' )
      echo $all_repos
  
      total_repos=$( echo $all_repos | sed 's/\"//g' | wc -w | sed 's/ //g' )
      echo "total_repos: $total_repos"

      for (( j=1; j<=$total_repos; j++ ))
      do

        repo=$( echo ${all_repos[0]} | cut -f $j -d " " )
        echo "  $j: $repo"

        # push call to add email service hook
        curl -H "$token_cmd" --data "{\"name\":\"email\",\"active\":\"true\",\"events\":[\"push\"],\"config\":{\"address\":\"$email\"}}" "$url/repos/$org/$repo/hooks"

      done
    else
      for (( k=1; k<=$last_repo_page; k++ ))
      do
        all_repos=$( curl -H "$token_cmd" "$url/orgs/$org/repos?type=$t&page=$k" | jq '.[].name' | sed 's/\"//g' )
        echo $all_repos
  
        total_repos=$( echo $all_repos | sed 's/\"//g' | wc -w | sed 's/ //g' )
        echo "total_repos: $total_repos"

        for (( j=1; j<=$total_repos; j++ ))
        do

          repo=$( echo ${all_repos[0]} | cut -f $j -d " " )
          echo "  $j: $repo"

          # push call to add email service hook
          curl -H "$token_cmd" --data "{\"name\":\"email\",\"active\":\"true\",\"events\":[\"push\"],\"config\":{\"address\":\"$email\"}}" "$url/repos/$org/$repo/hooks"

        done
      done 
    fi      #end last_repo_page == ""
  done      #end total_orgs
done        #end repo_types

echo ""
echo "End of script."

exit 0
